// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hopeless/screens/prescripitons/schedule_prescription.dart';
import 'package:hopeless/services/search_med_api.dart';
import 'package:hopeless/services/patient_prescription_service.dart';

class MakePrescriptionScreen extends StatefulWidget {
  const MakePrescriptionScreen({super.key});

  @override
  State<MakePrescriptionScreen> createState() => _MakePrescriptionScreenState();
}

class _MakePrescriptionScreenState extends State<MakePrescriptionScreen> {
  File? _imageFile;
  String? fallbackImageUrl;

  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  List<Map<String, dynamic>> _medicineResults = [];
  Map<String, dynamic>? _selectedMedicine;
  bool _isSearching = false;

  final Set<String> _selectedDays = {};
  bool _everyDaySelected = false;
  int _frequencyPerDay = 1;
  String _mealRelation = 'with_meal';

  final _days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
  final _dayKeys = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  int? _createdPrescriptionId;

  static const mealOptions = {
    'with_meal': 'بعد الأكل',
    'before_meal': 'قبل الأكل',
    'mid_meal': 'في منتصف الأكل',
    'no_relation': 'بدون علاقة',
    'empty_stomach': 'على الفراغ',
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        fallbackImageUrl = null;
      });
    }
  }

  Future<void> _searchMedicines(String query) async {
    setState(() => _isSearching = true);
    final results = await MedicineApi.search(query);
    setState(() {
      _medicineResults = results;
      _isSearching = false;
    });

    if (results.isNotEmpty) {
      final med = results.first;
      fallbackImageUrl = await PrescriptionService.fetchMedicineImageUrl(med['id']);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
        }
      });
    }
  }

Future<void> _handleNext() async {
  if (_selectedMedicine == null) {
    _showMsg('يرجى اختيار الدواء');
    return;
  }

  // 🌀 Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF112A54),
      ),
    ),
  );

  final result = await PrescriptionService.submitPrescription(
    medicineId: _selectedMedicine!['id'],
    startDate: _startDate.toIso8601String().split('T').first,
    endDate: _endDate.toIso8601String().split('T').first,
    frequencyPerDay: _frequencyPerDay,
    frequencyPerWeek: _everyDaySelected ? _dayKeys : _selectedDays.toList(),
    mealRelation: _mealRelation,
    instructions: _instructionsController.text.trim(),
    imageFile: _imageFile,
  );

  // ❌ Remove loading dialog
  if (mounted) Navigator.pop(context);

  if (result.success && result.prescriptionId != null) {
    _createdPrescriptionId = result.prescriptionId;

   Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ScheduleStepScreen(
      prescriptionId: _createdPrescriptionId!,
      frequencyPerDay: _frequencyPerDay, // 👈 Pass it here
    ),
  ),
);

  } else if (result.conflict) {
    _showMsg('⚠️ الوصفة موجودة مسبقاً');
  } else {
    _showMsg('❌ فشل في حفظ الوصفة');
  }
}


  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء وصفة', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF112A54),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildStep1(),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : fallbackImageUrl != null
                        ? Image.network(fallbackImageUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _medicineController,
            onChanged: _searchMedicines,
            decoration: const InputDecoration(labelText: 'اسم الدواء'),
          ),
          if (_isSearching) const LinearProgressIndicator(),
          ..._medicineResults.map((med) => ListTile(
                title: Text(med['brand_name']),
                subtitle: Text(med['dci']),
                onTap: () => setState(() {
                  _selectedMedicine = med;
                  _medicineController.text = med['brand_name'];
                  _medicineResults.clear();
                }),
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(isStart: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'تاريخ بدء الدواء'),
                    child: Text(
                      _startDate.toLocal().toString().split(' ')[0],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(isStart: false),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'تاريخ الانتهاء من الدواء'),
                    child: Text(
                      _endDate.toLocal().toString().split(' ')[0],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _frequencyPerDay,
            decoration: const InputDecoration(labelText: 'عدد المرات في اليوم'),
            items: List.generate(6, (i) => i + 1)
                .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                .toList(),
            onChanged: (val) => setState(() => _frequencyPerDay = val!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField(
            value: _mealRelation,
            decoration: const InputDecoration(labelText: 'العلاقة مع الأكل'),
            items: mealOptions.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (val) => setState(() => _mealRelation = val!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _instructionsController,
            decoration: const InputDecoration(labelText: 'تعليمات إضافية (اختياري)'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text('أيام التذكير'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilterChip(
                label: const Text('كل الأيام'),
                selected: _everyDaySelected,
                onSelected: (val) {
                  setState(() {
                    _everyDaySelected = val;
                    if (val) _selectedDays.clear();
                  });
                },
                shape: const StadiumBorder(),
                backgroundColor: const Color(0xFFE3F2FD),
              ),
              ..._dayKeys.asMap().entries.map((entry) {
                final key = entry.value;
                final label = _days[entry.key];
                return FilterChip(
                  label: Text(label),
                  selected: _selectedDays.contains(key),
                  onSelected: _everyDaySelected
                      ? null
                      : (val) => setState(() =>
                          val ? _selectedDays.add(key) : _selectedDays.remove(key)),
                  shape: const StadiumBorder(),
                  backgroundColor: const Color(0xFFE3F2FD),
                );
              })
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF112A54),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _handleNext,
            child: const Text('التالي'),
          ),
        ],
      ),
    );
  }
}
