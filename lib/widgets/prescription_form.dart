import 'package:flutter/material.dart';

class PrescriptionForm extends StatefulWidget {
  final Map<String, dynamic> medicine;

  const PrescriptionForm({super.key, required this.medicine});

  @override
  State<PrescriptionForm> createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  List<TimeOfDay> _times = [TimeOfDay.now()];
  List<int> _posologies = [1];
  String _mealRelation = 'with_meal';
  Set<String> _selectedDays = {'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};

  static const darkText = Color(0xFF3C3C3C);

  static const dayLabels = {
    'Everyday': 'كل الأيام',
    'Sat': 'السبت',
    'Sun': 'الأحد',
    'Mon': 'الإثنين',
    'Tue': 'الثلاثاء',
    'Wed': 'الأربعاء',
    'Thu': 'الخميس',
    'Fri': 'الجمعة',
  };

  static const mealOptions = {
    'with_meal': 'بعد الأكل',
    'before_meal': 'قبل الأكل',
    'mid_meal': 'في منتصف الأكل',
    'no_relation': 'بدون علاقة',
    'empty_stomach': 'على الفراغ',
  };

  void _addTimeAndDose() {
    setState(() {
      _times.add(TimeOfDay.now());
      _posologies.add(1);
    });
  }

  Widget buildDaysSelector() {
    return Wrap(
      spacing: 4,
      runSpacing: 0,
      children: dayLabels.entries.map((entry) {
        final isSelected = _selectedDays.contains(entry.key);

        return ChoiceChip(
          showCheckmark: false,
          label: Text(
            entry.value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : darkText,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (entry.key == 'Everyday') {
                if (isSelected) {
                  _selectedDays.clear(); // Unselect all
                } else {
                  _selectedDays =
                      Set.from(dayLabels.keys.where((k) => k != 'Everyday'));
                }
              } else {
                if (_selectedDays.contains('Everyday')) {
                  _selectedDays.remove('Everyday');
                }
                selected
                    ? _selectedDays.add(entry.key)
                    : _selectedDays.remove(entry.key);
              }
            });
          },
          selectedColor: const Color(0xFF1A237E),
          backgroundColor: const Color(0xFFF0F4FF),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medicine;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("معلومات الدواء"),
              const SizedBox(height: 10),
              _infoRow("اسم الدواء", med['brand_name']),
              _infoRow("المادة الفعالة", med['dci']),
              const SizedBox(height: 20),
              _sectionTitle("أوقات وتفاصيل الجرعات"),
              const SizedBox(height: 16),
              Column(
               children: List.generate(_times.length, (i) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عدد الحبات
        Expanded(
          child: DropdownButtonFormField<int>(
            isDense: true,
            value: _posologies[i],
            decoration: InputDecoration(
              labelText: "عدد الحبات",
              labelStyle: const TextStyle(color: darkText, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
            ),
            style: const TextStyle(fontSize: 14, color: darkText),
            items: [1, 2, 3, 4].map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text('$p', style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
            onChanged: (val) => setState(() => _posologies[i] = val!),
          ),
        ),
        const SizedBox(width: 8),

        // وقت التذكير
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _times[i],
                initialEntryMode: TimePickerEntryMode.input,
              );
              if (picked != null) {
                setState(() => _times[i] = picked);
              }
            },
            child: InputDecorator(
              isEmpty: false,
              decoration: InputDecoration(
                labelText: "وقت التذكير",
                labelStyle: const TextStyle(fontSize: 14, color: darkText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _times[i].format(context),
                    style: const TextStyle(fontSize: 12, color: darkText),
                  ),
                  const Icon(Icons.access_time, size: 16),
                ],
              ),
            ),
          ),
        ),

        // delete icon (compact)
        if (_times.length > 1)
          IconButton(
            padding: const EdgeInsets.only(right: 4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: () {
              setState(() {
                _times.removeAt(i);
                _posologies.removeAt(i);
              });
            },
            icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
            tooltip: "حذف التوقيت",
          ),
      ],
    ),
  );
}),

              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addTimeAndDose,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text("إضافة توقيت جديد"),
                ),
              ),
              const SizedBox(height: 10),
              _sectionTitle("الأيام التي تؤخذ فيها الجرعة"),
              const SizedBox(height: 12),
              buildDaysSelector(),
              const SizedBox(height: 20),
              _sectionTitle("العلاقة مع الأكل"),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _mealRelation,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF0F4FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: mealOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Row(
                      children: [
                        const Icon(Icons.restaurant, size: 18, color: darkText),
                        const SizedBox(width: 8),
                        Text(
                          entry.value,
                          style: const TextStyle(fontSize: 12, color: darkText),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _mealRelation = val!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "تأكيد الوصفة",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _submitPrescription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
      ),
    );
  }

  Widget _infoRow(String value, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF838383),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _submitPrescription() {
    final timesFormatted = _times.map((t) => '${t.hour}:${t.minute}').toList();
    final med = widget.medicine;

    final prescription = {
      'medicine_id': med['id'],
      'brand_name': med['brand_name'],
      'dci': med['dci'],
      'frequency_per_day': _times.length,
      'schedules': List.generate(
        _times.length,
        (i) => {
          'time': timesFormatted[i],
          'posology': _posologies[i],
        },
      ),
      'days': _selectedDays.toList(),
      'meal_relation': _mealRelation,
    };

    print('[✅ Prescription submitted]:\n$prescription');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم توليد وصفة الدواء')),
    );
  }
}
