import 'package:flutter/material.dart';

class DoseTimeEntryCard extends StatelessWidget {
  final int index;
  final int dose;
  final TimeOfDay time;
  final Function(int) onDoseChanged;
  final Function(TimeOfDay) onTimeChanged;

  const DoseTimeEntryCard({
    super.key,
    required this.index,
    required this.dose,
    required this.time,
    required this.onDoseChanged,
    required this.onTimeChanged,
  });

  String format24h(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الجرعة رقم ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            // Divider inside the card
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                // Dosage field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عدد الحبات',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: dose,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: [1, 2, 3, 4]
                            .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) onDoseChanged(val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Time field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوقت',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (picked != null) onTimeChanged(picked);
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            controller: TextEditingController(text: format24h(time)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
