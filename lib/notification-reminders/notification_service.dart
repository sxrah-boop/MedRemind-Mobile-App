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
  /// Initializes notifications, permission checks, and listeners
  static Future<void> init() async {
    debugPrint('[🔔 INIT] Initializing notifications...');
    await initializeNotifications();

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      debugPrint('[🔕 Permission] Requesting permission...');
      final granted = await AwesomeNotifications().requestPermissionToSendNotifications();
      if (!granted) {
        debugPrint('[❌ Permission] User denied notification permission.');
      } else {
        debugPrint('[✅ Permission] Permission granted.');
      }
    }

    final initialAction = await AwesomeNotifications().getInitialNotificationAction(removeFromActionEvents: false);
    if (initialAction?.payload != null) {
      debugPrint('[📦 Payload] Saving initial payload for navigation: ${initialAction!.payload}');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('initial_payload', jsonEncode(initialAction.payload));
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
    );

    debugPrint('[✅ INIT] Notification system ready.');
  }

  static Future<void> initializeNotifications() async {
    debugPrint('[🔧 Channel] Setting up notification channel...');
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'med_reminder_channel',
          channelName: 'Medical Reminders',
          channelDescription: 'Reminders to take your medication',
          defaultColor: const Color(0xFF03905D),
          importance: NotificationImportance.High,
        ),
      ],
      debug: true,
    );
  }

  /// Fetch prescription again and reschedule
  static Future<void> syncAndScheduleNotifications(int prescriptionId) async {
    try {
      debugPrint('[🔄 Sync] Fetching updated prescription: $prescriptionId...');
      final fullPrescription = await PrescriptionService.getPrescriptionById(prescriptionId);

      if (fullPrescription != null) {
        debugPrint('[📦 Sync] Prescription fetched. Rescheduling...');
        await cancelPrescriptionNotifications(prescriptionId);
        await schedulePrescriptionNotifications(fullPrescription);
      } else {
        debugPrint('[⚠️ Sync] Prescription $prescriptionId not found!');
      }
    } catch (e) {
      debugPrint('❌ Failed to sync & schedule notifications: $e');
    }
  }

  static Future<void> schedulePrescriptionNotifications(Prescription prescription) async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      debugPrint('[🚫 Schedule] Notifications not allowed for prescription ${prescription.id}');
      return;
    }

    final dayMap = {
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
    };

    debugPrint('[📅 Schedule] Scheduling for "${prescription.medicineName}"');

    for (final day in prescription.frequencyPerWeek) {
      final weekday = dayMap[day];
      if (weekday == null) continue;

      for (int i = 0; i < prescription.schedules.length; i++) {
        final schedule = prescription.schedules[i];
        final parts = schedule.horaire.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final notificationId = _generateUniqueId(prescription.id, i, weekday);

        debugPrint('[🔔 Creating] ID $notificationId on $day at $hour:$minute');

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: 'med_reminder_channel',
            title: '💊 ${prescription.medicineName}',
            body: '${prescription.instructions}\nالجرعة: ${schedule.posologie}، مع ${_translateMeal(prescription.mealRelation)}',
            notificationLayout: NotificationLayout.BigPicture,
            bigPicture: prescription.medicineImage.startsWith('http')
                ? prescription.medicineImage
                : 'asset://${prescription.medicineImage}',
            payload: {
              'screen': 'notification',
               'horaireId': '${schedule.id}',            // ✅ Add this
               'notificationId': '$notificationId', 
              'prescriptionId': '${prescription.id}',
              'medicineName': prescription.medicineName,
              'dose': '${schedule.posologie}',
              'horaire': schedule.horaire,
              'mealRelation': prescription.mealRelation,
              'instructions': prescription.instructions,
              'image': prescription.medicineImage ?? '',
            },
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
          actionButtons: [
            NotificationActionButton(key: 'TAKEN', label: 'تم التناول ✅'),
            NotificationActionButton(key: 'REMIND_LATER', label: 'ذكرني لاحقًا ⏰'),
          ],
        );
      }
    }

    debugPrint('[✅ Schedule] Notifications created for ${prescription.id}');
  }

  static Future<void> cancelPrescriptionNotifications(int prescriptionId) async {
    debugPrint('[🗑️ Cancel] Cancelling notifications for $prescriptionId...');
    for (int i = 0; i < 100; i++) {
      final id = prescriptionId * 100 + i;
      await AwesomeNotifications().cancel(id);
    }
    debugPrint('[✅ Cancel] All notifications cleared for $prescriptionId');
  }

@pragma('vm:entry-point')
static Future<void> _onActionReceived(ReceivedAction action) async {
  debugPrint('📲 Notification Action Received: ${action.toMap()}');

  final payload = action.payload?.map((key, value) => MapEntry(key, value ?? ''));

  // 🧠 Helper to show feedback if navKey has context
  void showSnack(String message) {
    final context = navKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.center),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      debugPrint('⚠️ Unable to show snackbar – context is null');
    }
  }

  // 🔹 Handle "TAKEN"
  if (action.buttonKeyPressed == 'TAKEN') {
    debugPrint('✅ Action: Medication Taken');

    if (payload != null) {
      try {
        final horaireId = int.parse(payload['horaireId']!);
        final scheduledTimeStr = payload['horaire']!;
        final notificationId = int.parse(payload['notificationId']!);

        await handleDoseConfirmation(
          horaireId: horaireId,
          scheduledTimeStr: scheduledTimeStr,
          notificationId: notificationId,
        );
        showSnack('✅ تم تسجيل الجرعة');
      } catch (e) {
        debugPrint('❌ [Error TAKEN]: $e');
        showSnack('❌ حدث خطأ أثناء تسجيل الجرعة');
      }
    } else {
      debugPrint('⚠️ [TAKEN] No payload available');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navKey.currentState?.pushNamedAndRemoveUntil('/home', (_) => false);
    });

    return;
  }

  // 🔹 Handle "REMIND_LATER"
  if (action.buttonKeyPressed == 'REMIND_LATER') {
    debugPrint('⏰ Action: Remind Me Later');

    if (payload != null) {
      try {
        await scheduleRemindLaterNotification(payload);
        showSnack('⏰ سيتم التذكير بعد 10 دقائق');
      } catch (e) {
        debugPrint('❌ [Error REMIND_LATER]: $e');
        showSnack('❌ فشل في جدولة التذكير');
      }
    } else {
      debugPrint('⚠️ [REMIND_LATER] No payload available');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navKey.currentState?.pushNamedAndRemoveUntil('/home', (_) => false);
    });

    return;
  }

  // 🔹 Tapped body of the notification
  if (payload?['screen'] == 'notification') {
    debugPrint('🖱️ Notification tapped → Navigating to notification screen');

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
      case 'before_meal':
        return 'قبل الأكل';
      case 'with_meal':
        return 'مع الأكل';
      case 'after_meal':
        return 'بعد الأكل';
      case 'mid_meal':
        return 'منتصف الأكل';
      case 'empty_stomach':
        return 'على معدة فارغة';
      default:
        return 'الطعام';
    }
  }

static Future<void> scheduleRemindLaterNotification(Map<String, String> payload) async {
 final now = DateTime.now();
final remindAt = now.add(const Duration(minutes: 10));
Future<void> scheduleRemindLaterNotification(Map<String, String> originalPayload) async {
  final remindAt = DateTime.now().add(const Duration(minutes: 10));
  final newId = remindAt.millisecondsSinceEpoch.remainder(100000);

  debugPrint('🔁 Scheduling reminder for ${remindAt.toLocal()} with ID $newId');

  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: newId,
        channelKey: 'med_reminder_channel',
        title: '💊 تذكير: لم تتناول دواءك بعد!',
        body: 'اضغط لعرض تفاصيل الدواء واتخاذ الإجراء المناسب.',
        notificationLayout: NotificationLayout.BigPicture,
        bigPicture: originalPayload['image']?.startsWith('http') == true
            ? originalPayload['image']!
            : 'asset://${originalPayload['image']}',
        payload: {
          ...originalPayload,
          'screen': 'notification',
        },
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
    debugPrint('✅ Remind-later notification scheduled successfully.');
  } catch (e) {
    debugPrint('❌ Failed to schedule remind-later notification: $e');
  }
}
}
  
  
  static Future<void> handleDoseConfirmation({
    required int horaireId,
    required String scheduledTimeStr, // "HH:mm:ss"
    required int notificationId,
    BuildContext? context, // optional for feedback
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final parts = scheduledTimeStr.split(':');
      final scheduled = DateTime(
        today.year,
        today.month,
        today.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      final diff = now.difference(scheduled).inMinutes;
      final horairePriseActuel = now.toIso8601String();

      // 🚨 Too late (>3 hours): mark missed
      if (diff > 180) {
        debugPrint('⏰ Dose missed after 3+ hours (diff: $diff min)');
        await _submitToBackend(
          horaireId: horaireId,
          statut: 'missed',
          horairePriseActuel: horairePriseActuel,
        );
        await AwesomeNotifications().cancel(notificationId);

        if (context != null) {
          _showFeedback(context, '⏰ تم اعتبار الجرعة فائتة بعد ٣ ساعات');
        }
        return;
      }

      // ✅ Normal range
      final status = diff.abs() <= 30 ? 'taken' : 'late';
      debugPrint('💊 Dose status determined: $status (diff: $diff min)');

      await _submitToBackend(
        horaireId: horaireId,
        statut: status,
        horairePriseActuel: horairePriseActuel,
      );

      await AwesomeNotifications().cancel(notificationId);

      if (context != null) {
        if (status == 'taken') {
          _showFeedback(context, '✅ تم تسجيل الجرعة بنجاح');
        } else {
          _showFeedback(context, '⌛ تم تسجيل الجرعة لكنها متأخرة');
        }
      }
    } catch (e) {
      debugPrint('❌ Error in handleDoseConfirmation: $e');
      if (context != null) {
        _showFeedback(context, 'حدث خطأ أثناء تسجيل الجرعة');
      }
    }
  }

static Future<void> _submitToBackend({
  required int horaireId,
  required String statut,
  required String horairePriseActuel,
}) async {
  debugPrint('[📤 Confirm Dose] ID: $horaireId | Status: $statut | At: $horairePriseActuel');

  final user = FirebaseAuth.instance.currentUser;
  final token = await user?.getIdToken();

  if (token == null) {
    throw Exception("⚠️ Firebase token not found");
  }

  final dio = Dio();

  try {
    final response = await dio.post(
      'https://medremind.onrender.com/api/prise/confirm/',
      data: {
        "horaire_id": horaireId,
        "statut": statut,
        "horaire_prise_actuel": horairePriseActuel
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    debugPrint('✅ Backend Response: ${response.statusCode} ${response.data}');
  } catch (e) {
    debugPrint('❌ Error submitting dose confirmation: $e');
    rethrow;
  }
}

  static void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 3),
      ),
    );
  }

}
