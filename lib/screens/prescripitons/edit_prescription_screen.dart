import 'package:flutter/material.dart';
import 'package:hopeless/models/prescription_model.dart';
import 'package:hopeless/services/edit_delete_prescription_service.dart';
import 'package:hopeless/widgets/DoseTimeEntryCard.dart';
import 'package:hopeless/notification-reminders/notification_service.dart';

class EditPrescriptionPage extends StatefulWidget {
  final Prescription prescription;

  const EditPrescriptionPage({super.key, required this.prescription});

  @override
  State<EditPrescriptionPage> createState() => _EditPrescriptionPageState();
}

class _EditPrescriptionPageState extends State<EditPrescriptionPage> {
  late int frequencyPerDay;
  late Set<String> selectedDays;
  late String mealRelation;
  late TextEditingController instructionsController;

  late List<TimeOfDay> _times;
  late List<int> _doses;
  bool _isSubmitting = false;

  final List<String> allDays = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];
  final Map<String, String> dayLabels = {
    'Sat': 'السبت',
    'Sun': 'الأحد',
    'Mon': 'الإثنين',
    'Tue': 'الثلاثاء',
    'Wed': 'الأربعاء',
    'Thu': 'الخميس',
    'Fri': 'الجمعة',
  };
  final Map<String, String> mealOptions = {
    'with_meal': 'مع الأكل',
    'before_meal': 'قبل الأكل',
    'mid_meal': 'منتصف الأكل',
    'no_relation': 'بدون علاقة',
    'empty_stomach': 'على معدة فارغة',
  };

  @override
  void initState() {
    super.initState();
    frequencyPerDay = widget.prescription.frequencyPerDay;
    selectedDays = widget.prescription.frequencyPerWeek.toSet();
    mealRelation = widget.prescription.mealRelation;
    instructionsController = TextEditingController(
      text: widget.prescription.instructions,
    );

    _times =
        widget.prescription.schedules
            .map(
              (s) => TimeOfDay(
                hour: int.parse(s.horaire.split(":")[0]),
                minute: int.parse(s.horaire.split(":")[1]),
              ),
            )
            .toList();

    _doses = widget.prescription.schedules.map((s) => s.posologie).toList();

    while (_times.length < frequencyPerDay) {
      _times.add(TimeOfDay.now());
      _doses.add(1);
    }
    while (_times.length > frequencyPerDay) {
      _times.removeLast();
      _doses.removeLast();
    }
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    final updatedSchedule = List.generate(
      frequencyPerDay,
      (i) => {'horaire': _formatTime(_times[i]), 'posologie': _doses[i]},
    );

    final updatePresSuccess =
        await PrescriptionEditDeleteService.updatePrescription(
          prescriptionId: widget.prescription.id,
          frequencyPerDay: frequencyPerDay,
          frequencyPerWeek: selectedDays.toList(),
          mealRelation: mealRelation,
          instructions: instructionsController.text,
        );

    final updateSchedSuccess =
        await PrescriptionEditDeleteService.updateSchedules(
          widget.prescription.id,
          updatedSchedule,
        );

    if (updatePresSuccess && updateSchedSuccess) {
      await NotificationService.syncAndScheduleNotifications(
        widget.prescription.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم حفظ التعديلات وتحديث التذكيرات')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في تحديث الوصفة أو الجدول')),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF112A54),
          title: const Text(
            'تعديل الوصفة',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                widget.prescription.medicineName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 12, 15, 158),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: frequencyPerDay,
                decoration: const InputDecoration(
                  labelText: 'عدد المرات في اليوم',
                ),
                items:
                    List.generate(6, (i) => i + 1)
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text('$e')),
                        )
                        .toList(),
                onChanged:
                    (val) => setState(() {
                      frequencyPerDay = val!;
                      while (_times.length < frequencyPerDay) {
                        _times.add(TimeOfDay.now());
                        _doses.add(1);
                      }
                      while (_times.length > frequencyPerDay) {
                        _times.removeLast();
                        _doses.removeLast();
                      }
                    }),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'أيام الأسبوع',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Wrap(
                spacing: 6,
                children:
                    allDays.map((day) {
                      return FilterChip(
                        label: Text(dayLabels[day]!),
                        selected: selectedDays.contains(day),
                        onSelected:
                            (val) => setState(() {
                              val
                                  ? selectedDays.add(day)
                                  : selectedDays.remove(day);
                            }),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: mealRelation,
                decoration: const InputDecoration(
                  labelText: 'العلاقة مع الأكل',
                ),
                items:
                    mealOptions.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => mealRelation = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(labelText: 'تعليمات إضافية'),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                frequencyPerDay,
                (i) => DoseTimeEntryCard(
                  index: i,
                  dose: _doses[i],
                  time: _times[i],
                  onDoseChanged: (val) => setState(() => _doses[i] = val),
                  onTimeChanged: (val) => setState(() => _times[i] = val),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: const Icon(Icons.save),
                label:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('حفظ التعديلات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF112A54),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
