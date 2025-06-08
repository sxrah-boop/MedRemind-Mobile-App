// import 'package:flutter/material.dart';
// import 'package:hopeless/models/prescription_model.dart';

// class EditPrescriptionModal extends StatefulWidget {
//   final Prescription prescription;
//   final void Function(Map<String, dynamic> updatedFields) onSubmit;

//   const EditPrescriptionModal({
//     super.key,
//     required this.prescription,
//     required this.onSubmit,
//   });

//   @override
//   State<EditPrescriptionModal> createState() => _EditPrescriptionModalState();
// }

// class _EditPrescriptionModalState extends State<EditPrescriptionModal> {
//   late int frequencyPerDay;
//   late Set<String> selectedDays;
//   late String mealRelation;
//   late TextEditingController instructionsController;

//   final List<String> allDays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
//   final Map<String, String> dayLabels = {
//     'Sat': 'السبت',
//     'Sun': 'الأحد',
//     'Mon': 'الإثنين',
//     'Tue': 'الثلاثاء',
//     'Wed': 'الأربعاء',
//     'Thu': 'الخميس',
//     'Fri': 'الجمعة'
//   };

//   final Map<String, String> mealOptions = {
//     'with_meal': 'مع الأكل',
//     'before_meal': 'قبل الأكل',
//     'mid_meal': 'منتصف الأكل',
//     'no_relation': 'بدون علاقة',
//     'empty_stomach': 'على معدة فارغة',
//   };

//   @override
//   void initState() {
//     super.initState();
//     frequencyPerDay = widget.prescription.frequencyPerDay;
//     selectedDays = widget.prescription.frequencyPerWeek.toSet();
//     mealRelation = widget.prescription.mealRelation;
//     instructionsController = TextEditingController(text: widget.prescription.instructions);
//   }

//   void _submit() {
//     final data = {
//       'frequency_per_day': frequencyPerDay,
//       'frequency_per_week': selectedDays.toList(),
//       'meal_relation': mealRelation,
//       'instructions': instructionsController.text,
//     };
//     widget.onSubmit(data);
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('تعديل الوصفة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),

//             DropdownButtonFormField<int>(
//               value: frequencyPerDay,
//               decoration: const InputDecoration(labelText: 'عدد المرات في اليوم'),
//               items: List.generate(6, (i) => i + 1)
//                   .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
//                   .toList(),
//               onChanged: (val) => setState(() => frequencyPerDay = val!),
//             ),

//             const SizedBox(height: 12),
//             const Align(
//               alignment: Alignment.centerRight,
//               child: Text('أيام الأسبوع', style: TextStyle(fontWeight: FontWeight.w600)),
//             ),
//             Wrap(
//               spacing: 6,
//               children: allDays.map((day) => FilterChip(
//                 label: Text(dayLabels[day]!),
//                 selected: selectedDays.contains(day),
//                 onSelected: (val) => setState(() {
//                   val ? selectedDays.add(day) : selectedDays.remove(day);
//                 }),
//               )).toList(),
//             ),

//             const SizedBox(height: 12),
//             DropdownButtonFormField(
//               value: mealRelation,
//               decoration: const InputDecoration(labelText: 'العلاقة مع الأكل'),
//               items: mealOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
//               onChanged: (val) => setState(() => mealRelation = val!),
//             ),

//             const SizedBox(height: 12),
//             TextField(
//               controller: instructionsController,
//               decoration: const InputDecoration(labelText: 'تعليمات إضافية'),
//               maxLines: 2,
//             ),

//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _submit,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF112A54),
//               ),
//               child: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
