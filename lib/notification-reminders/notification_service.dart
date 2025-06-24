import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hopeless/main.dart';
import 'package:hopeless/services/list_prescriptions_service_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prescription_model.dart';

class NotificationService {
  // Track processed notifications to prevent double processing
  static final Set<String> _processedNotifications = <String>{};
  
  static Future<void> init() async {
    debugPrint('[🔔 INIT] Initializing notifications...');
    await initializeNotifications();

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      final granted = await AwesomeNotifications().requestPermissionToSendNotifications();
      if (!granted) {
        debugPrint('[❌ Permission] User denied notification permission.');
      } else {
        debugPrint('[✅ Permission] Permission granted.');
      }
    }

    final initialAction = await AwesomeNotifications().getInitialNotificationAction(removeFromActionEvents: false);
    if (initialAction?.payload != null) {
      debugPrint('[📦 Payload] Saving initial payload: ${initialAction!.payload}');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('initial_payload', jsonEncode(initialAction.payload));
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
    );

    debugPrint('[✅ INIT] Notification system ready.');
  }

  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'med_reminder_channel',
        channelName: 'Medical Reminders',
        channelDescription: 'Reminders to take your medication',
        defaultColor: const Color(0xFF03905D),
        importance: NotificationImportance.High,
      ),
    ], debug: true);
  }

  static Future<void> syncAndScheduleNotifications(int prescriptionId) async {
    try {
      final fullPrescription = await PrescriptionService.getPrescriptionById(prescriptionId);
      if (fullPrescription != null) {
        await cancelPrescriptionNotifications(prescriptionId);
        await schedulePrescriptionNotifications(fullPrescription);
      }
    } catch (e) {
      debugPrint('❌ Sync error: $e');
    }
  }

  static Future<void> schedulePrescriptionNotifications(Prescription prescription) async {
    final dayMap = {
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
    };

    final expandedDays = prescription.frequencyPerWeek.contains('Everyday')
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : prescription.frequencyPerWeek;

    for (final day in expandedDays) {
      final weekday = dayMap[day];
      if (weekday == null) continue;

      for (int i = 0; i < prescription.schedules.length; i++) {
        final schedule = prescription.schedules[i];
        debugPrint('[🐞 DEBUG HORAIRE_ID] Creating notification for horaireId=${schedule.id}');

        final parts = schedule.horaire.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final notificationId = _generateUniqueId(prescription.id, i, weekday);

        final payload = {
          'screen': 'notification',
          'horaireId': '${schedule.id}',
          'notificationId': '$notificationId',
          'prescriptionId': '${prescription.id}',
          'medicineName': prescription.medicineName,
          'dose': '${schedule.posologie}',
          'horaire': schedule.horaire,
          'mealRelation': prescription.mealRelation,
          'instructions': prescription.instructions,
          'image': prescription.medicineImage.toString(),
          'dayKey': day,
          'medicineId': prescription.medicineId.toString()
        };

        debugPrint('[🧪 DEBUG PAYLOAD CREATE] $payload');

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: 'med_reminder_channel',
            title: '💊 ${prescription.medicineName}',
            body: '${prescription.instructions}\nالجرعة: ${schedule.posologie}، مع ${_translateMeal(prescription.mealRelation)}',
            notificationLayout: NotificationLayout.BigPicture,
            bigPicture: prescription.medicineImage.toString().startsWith('http')
                ? prescription.medicineImage.toString()
                : 'asset://${prescription.medicineImage.toString()}',
            payload: payload,
          ),
          schedule: NotificationCalendar(
            preciseAlarm: true,
            weekday: weekday,
            hour: hour,
            minute: minute,
            second: 0,
            timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
            repeats: true,
          ),
          // actionButtons: [
          //   NotificationActionButton(key: 'TAKEN', label: 'تم التناول ✅'),
          //   NotificationActionButton(key: 'REMIND_LATER', label: 'ذكرني لاحقًا ⏰'),
          // ],
        );
      }
    }
  }

  static Future<void> cancelPrescriptionNotifications(int prescriptionId) async {
    for (int i = 0; i < 100; i++) {
      final id = prescriptionId * 100 + i;
      await AwesomeNotifications().cancel(id);
    }
  }

  @pragma('vm:entry-point')
 @pragma('vm:entry-point')
static Future<void> _onActionReceived(ReceivedAction action) async {
  debugPrint('📲 [onActionReceived] Full Action: ${action.toMap()}');

  final payload = action.payload?.map((key, value) => MapEntry(key, value ?? ''));
  debugPrint('📦 [onActionReceived] Payload received: $payload');

  if (action.buttonKeyPressed == 'TAKEN') {
    debugPrint('✅ Action TAKEN pressed');

    if (payload != null) {
      try {
        final horaireId = int.parse(payload['horaireId']!);
        final scheduledTimeStr = payload['horaire']!;
        final notificationId = int.parse(payload['notificationId']!);

        final isAlreadyProcessed = NotificationService.isDoseProcessedToday(horaireId);
        if (isAlreadyProcessed) {
          debugPrint('⚠️ Dose already processed — skipping confirmation and navigation');
          // Redirect to home to avoid reopening screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navKey.currentState?.pushNamedAndRemoveUntil('/home', (_) => false);
          });
          return;
        }

        await handleDoseConfirmation(
          horaireId: horaireId,
          scheduledTimeStr: scheduledTimeStr,
          notificationId: notificationId,
        );

        NotificationService.markDoseAsProcessed(horaireId);

        // After success, go home — NOT to the notification screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navKey.currentState?.pushNamedAndRemoveUntil('/home', (_) => false);
        });
        return;

      } catch (e) {
        debugPrint('❌ Error during TAKEN: $e');
      }
    }
  }

  if (action.buttonKeyPressed == 'REMIND_LATER') {
    debugPrint('⏰ Action REMIND_LATER pressed');
    if (payload != null) {
      await scheduleRemindLaterNotification(payload);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navKey.currentState?.pushNamedAndRemoveUntil('/home', (_) => false);
      });
    }
    return; // Stop here, don't open screen
  }

  // Only open the screen if the user tapped the notification (not a button)
  if ((action.buttonKeyPressed == null || action.buttonKeyPressed!.isEmpty) &&
      payload?['screen'] == 'notification') {
    final horaireId = int.tryParse(payload?['horaireId'] ?? '');
    final isTaken = horaireId != null && NotificationService.isDoseProcessedToday(horaireId);
    if (isTaken) {
      debugPrint('🛑 Notification tapped but dose was already taken, skipping navigation');
      return;
    }

    debugPrint('📍 Navigating to /notification with payload');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navKey.currentState?.pushNamedAndRemoveUntil(
        '/notification',
        (_) => false,
        arguments: payload,
      );
    });
  }
}

  static int _generateUniqueId(int prescriptionId, int scheduleIndex, int weekday) {
    return prescriptionId * 1000 + scheduleIndex * 10 + weekday;
  }

  static String _translateMeal(String relation) {
    switch (relation) {
      case 'before_meal': return 'قبل الأكل';
      case 'with_meal': return 'مع الأكل';
      case 'after_meal': return 'بعد الأكل';
      case 'mid_meal': return 'منتصف الأكل';
      case 'empty_stomach': return 'على معدة فارغة';
      default: return 'الطعام';
    }
  }

  static Future<void> scheduleRemindLaterNotification(Map<String, String> payload) async {
    final remindAt = DateTime.now().add(const Duration(minutes: 10));
    final newId = remindAt.millisecondsSinceEpoch.remainder(100000);
    debugPrint('🔁 Scheduling RemindLater at $remindAt for ID $newId');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: newId,
        channelKey: 'med_reminder_channel',
        title: '💊 تذكير: لم تتناول دواءك بعد!',
        body: 'اضغط لعرض تفاصيل الدواء واتخاذ الإجراء المناسب.',
        notificationLayout: NotificationLayout.BigPicture,
        bigPicture: payload['image']?.startsWith('http') == true
            ? payload['image']!
            : 'asset://${payload['image']}',
        payload: {...payload, 'screen': 'notification'},
      ),
      schedule: NotificationCalendar(
        year: remindAt.year,
        month: remindAt.month,
        day: remindAt.day,
        hour: remindAt.hour,
        minute: remindAt.minute,
        second: remindAt.second,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: false,
        preciseAlarm: true,
      ),
    );
  }

  static Future<void> handleDoseConfirmation({
    required int horaireId,
    required String scheduledTimeStr,
    required int notificationId,
  }) async {
    debugPrint('[🐞 DEBUG HORAIRE_ID] Handling confirmation for horaireId=$horaireId');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final parts = scheduledTimeStr.split(':');
    final scheduled = DateTime(today.year, today.month, today.day, int.parse(parts[0]), int.parse(parts[1]), parts.length > 2 ? int.parse(parts[2]) : 0);
    final diff = now.difference(scheduled).inMinutes;
    final status = diff > 180 ? 'missed' : (diff.abs() <= 30 ? 'taken' : 'late');
    final horairePriseActuel = now.toIso8601String();

    await _submitToBackend(horaireId: horaireId, statut: status, horairePriseActuel: horairePriseActuel);
    await AwesomeNotifications().cancel(notificationId);
  }

  static Future<void> _submitToBackend({
    required int horaireId,
    required String statut,
    required String horairePriseActuel,
  }) async {
    debugPrint('[📤 Backend Submit] horaireId=$horaireId | statut=$statut | at=$horairePriseActuel');
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception("⚠️ Firebase token missing");

    final dio = Dio();
    await dio.post(
      'https://medremind.onrender.com/api/prise/confirm/',
      data: {
        "horaire_id": horaireId,
        "statut": statut,
        "horaire_prise_actuel": horairePriseActuel,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // Method to clear processed notifications (call this daily or when needed)
  static void clearProcessedNotifications() {
    _processedNotifications.clear();
    debugPrint('🧹 Cleared processed notifications cache');
  }
  
  // Method to check if a dose was already processed today
  static bool isDoseProcessedToday(int horaireId) {
    final doseKey = '${horaireId}_${DateTime.now().toString().substring(0, 10)}';
    return _processedNotifications.contains(doseKey);
  }
   static void markDoseAsProcessed(int horaireId) {
    final doseKey = '${horaireId}_${DateTime.now().toString().substring(0, 10)}';
    _processedNotifications.add(doseKey);
    debugPrint('✅ Marked dose as processed: $doseKey');
  }
}