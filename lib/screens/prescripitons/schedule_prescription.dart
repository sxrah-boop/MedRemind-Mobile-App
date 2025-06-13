import 'package:flutter/material.dart';
import 'package:hopeless/services/patient_prescription_service.dart';
import 'package:hopeless/widgets/DoseTimeEntryCard.dart';
import 'package:hopeless/notification-reminders/notification_service.dart';

class ScheduleStepScreen extends StatefulWidget {
  final int prescriptionId;
  final int frequencyPerDay;

  const ScheduleStepScreen({
    super.key,
    required this.prescriptionId,
    required this.frequencyPerDay,
  });

  @override
  State<ScheduleStepScreen> createState() => _ScheduleStepScreenState();
}

class _ScheduleStepScreenState extends State<ScheduleStepScreen> {
  late List<TimeOfDay> _times;
  late List<int> _doses;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _times = List.generate(widget.frequencyPerDay, (_) => TimeOfDay.now());
    _doses = List.generate(widget.frequencyPerDay, (_) => 1);
  }

  String format24h(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _handleSubmit() async {
    final schedule = List.generate(_times.length, (i) => {
          'horaire': format24h(_times[i]),
          'posologie': _doses[i],
        });

    setState(() => _isSubmitting = true);

    try {
      final response = await PrescriptionService.submitScheduleWithResponse(
        prescriptionId: widget.prescriptionId,
        scheduleEntries: schedule,
      );

      final status = response.statusCode;
      final data = response.data;

      if (status == 201 || status == 207) {
        if (status == 207) {
          final errors = data['erreurs'] ?? [];
          final errorMsg = errors.isNotEmpty
              ? '⚠️ بعض الأوقات لم تُضف بسبب: ${errors.map((e) => e['erreur']).join(', ')}'
              : '⚠️ بعض الأوقات لم تُضف.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('✅ تم حفظ الجدول بنجاح')));
        }

        // ✅ Schedule the notifications
       await NotificationService.syncAndScheduleNotifications(widget.prescriptionId);

        // ✅ Navigate to home
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (status == 400 && data['erreur'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${data['erreur']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في إرسال الجدول')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ خطأ أثناء إرسال الجدول: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة جدول الجرعات', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF112A54),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'حدد عدد الجرعات ووقتها خلال اليوم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.frequencyPerDay,
                itemBuilder: (context, i) => DoseTimeEntryCard(
                  index: i,
                  dose: _doses[i],
                  time: _times[i],
                  onDoseChanged: (val) => setState(() => _doses[i] = val),
                  onTimeChanged: (val) => setState(() => _times[i] = val),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleSubmit,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ الجدول', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF112A54),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
