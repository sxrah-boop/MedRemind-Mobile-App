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
    
    // Debug: Print the instructions to see what's being loaded
    print('DEBUG: Prescription instructions: "${widget.prescription.instructions}"');
    
    instructionsController = TextEditingController(
      text: widget.prescription.instructions ?? '',
    );
    
    // Debug: Print controller text to verify it's set
    print('DEBUG: Controller text: "${instructionsController.text}"');

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
          SnackBar(
            content: const Text('✅ تم حفظ التعديلات وتحديث التذكيرات'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ فشل في تحديث الوصفة أو الجدول'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5E7EB).withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF112A54),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF112A54),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'تعديل الوصفة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Medicine Name Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF112A54),
                      const Color(0xFF112A54).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.medication,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.prescription.medicineName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Frequency Section
              _buildSectionCard(
                title: 'تكرار الجرعات',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: frequencyPerDay,
                      isExpanded: true,
                      hint: const Text('عدد المرات في اليوم'),
                      items: List.generate(6, (i) => i + 1)
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('$e مرات في اليوم'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() {
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
                  ),
                ),
              ),

              // Days Selection
              _buildSectionCard(
                title: 'أيام الأسبوع',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allDays.map((day) {
                    final isSelected = selectedDays.contains(day);
                    return GestureDetector(
                      onTap: () => setState(() {
                        isSelected
                            ? selectedDays.remove(day)
                            : selectedDays.add(day);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF112A54)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF112A54)
                                : const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          dayLabels[day]!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Meal Relation
              _buildSectionCard(
                title: 'العلاقة مع الأكل',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: mealRelation,
                      isExpanded: true,
                      items: mealOptions.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => mealRelation = val!),
                    ),
                  ),
                ),
              ),

              // Instructions Section (Larger)
              _buildSectionCard(
                title: 'تعليمات إضافية',
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Debug info (remove this after testing)
                      if (instructionsController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'موجود: ${instructionsController.text.length} حرف',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      TextField(
                        controller: instructionsController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: instructionsController.text.isEmpty 
                              ? 'أدخل أي تعليمات إضافية هنا...' 
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Schedule Section
              _buildSectionCard(
                title: 'جدول الجرعات',
                child: Column(
                  children: List.generate(
                    frequencyPerDay,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DoseTimeEntryCard(
                        index: i,
                        dose: _doses[i],
                        time: _times[i],
                        onDoseChanged: (val) => setState(() => _doses[i] = val),
                        onTimeChanged: (val) => setState(() => _times[i] = val),
                      ),
                    ),
                  ),
                ),
              ),

              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 20),
                  label: Text(
                    _isSubmitting ? 'جاري الحفظ...' : 'حفظ التعديلات',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF112A54),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: const Color(0xFF112A54).withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}