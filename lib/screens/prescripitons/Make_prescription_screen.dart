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

    if (mounted) Navigator.pop(context);

    if (result.success && result.prescriptionId != null) {
      _createdPrescriptionId = result.prescriptionId;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduleStepScreen(
            prescriptionId: _createdPrescriptionId!,
            frequencyPerDay: _frequencyPerDay,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFCFF),
        appBar: AppBar(
          title: const Text(
            'إنشاء وصفة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: const Color(0xFF112A54),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE1EFFF),
                        width: 2,
                      ),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : fallbackImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(fallbackImageUrl!, fit: BoxFit.cover),
                              )
                            : const Icon(
                                Icons.camera_alt_outlined,
                                size: 28,
                                color: Color(0xFF6B9DFF),
                              ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Medicine Search
              _buildInputField(
                label: 'اسم الدواء',
                child: TextField(
                  controller: _medicineController,
                  onChanged: _searchMedicines,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن الدواء',
                    hintStyle: TextStyle(color: Color(0xFF9BB5D6)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              if (_isSearching)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 2,
                  child: const LinearProgressIndicator(
                    backgroundColor: Color(0xFFE1EFFF),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B9DFF)),
                  ),
                ),

              if (_medicineResults.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE1EFFF)),
                  ),
                  child: Column(
                    children: _medicineResults.map((med) {
                      return ListTile(
                        title: Text(
                          med['brand_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          med['dci'],
                          style: const TextStyle(
                            color: Color(0xFF7A95B8),
                            fontSize: 13,
                          ),
                        ),
                        onTap: () => setState(() {
                          _selectedMedicine = med;
                          _medicineController.text = med['brand_name'];
                          _medicineResults.clear();
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Date Section
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'تاريخ البدء',
                      child: GestureDetector(
                        onTap: () => _pickDate(isStart: true),
                        child: Text(
                          _startDate.toLocal().toString().split(' ')[0],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildInputField(
                      label: 'تاريخ الانتهاء',
                      child: GestureDetector(
                        onTap: () => _pickDate(isStart: false),
                        child: Text(
                          _endDate.toLocal().toString().split(' ')[0],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Frequency Section
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'المرات يومياً',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _frequencyPerDay,
                          isExpanded: true,
                          items: List.generate(6, (i) => i + 1)
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text('$e مرة', style: const TextStyle(fontSize: 16)),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _frequencyPerDay = val!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildInputField(
                      label: 'مع الأكل',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _mealRelation,
                          isExpanded: true,
                          items: mealOptions.entries
                              .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value, style: const TextStyle(fontSize: 16)),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _mealRelation = val!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Days Section
              const Text(
                'أيام الأسبوع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildDayChip(
                    'كل الأيام',
                    _everyDaySelected,
                    () => setState(() {
                      _everyDaySelected = !_everyDaySelected;
                      if (_everyDaySelected) _selectedDays.clear();
                    }),
                    isSpecial: true,
                  ),
                  ..._dayKeys.asMap().entries.map((entry) {
                    final key = entry.value;
                    final label = _days[entry.key];
                    return _buildDayChip(
                      label,
                      _selectedDays.contains(key),
                      _everyDaySelected
                          ? null
                          : () => setState(() => _selectedDays.contains(key)
                              ? _selectedDays.remove(key)
                              : _selectedDays.add(key)),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 32),

              // Instructions
              _buildInputField(
                label: 'تعليمات إضافية',
                child: TextField(
                  controller: _instructionsController,
                  maxLines: 3,
                  minLines: 3,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'أضف تعليمات خاصة للمريض...',
                    hintStyle: TextStyle(color: Color(0xFF9BB5D6)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF112A54),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _handleNext,
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1EFFF), width: 1.5),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDayChip(String label, bool isSelected, VoidCallback? onTap, {bool isSpecial = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isSpecial ? const Color(0xFF112A54) : const Color(0xFF6B9DFF))
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? (isSpecial ? const Color(0xFF112A54) : const Color(0xFF6B9DFF))
                : const Color(0xFFE1EFFF),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4A5568),
            fontWeight: FontWeight.w500,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}