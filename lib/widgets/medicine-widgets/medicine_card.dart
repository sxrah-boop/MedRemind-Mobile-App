// import 'package:flutter/material.dart';
// import 'package:hopeless/screens/medicine-screens/medicine_details_screen.dart'; // Update the path as needed

// class MedicineCard extends StatelessWidget {
//   final String name;
//   final String substance;
//   final String frequency;
//   final String dosageInfoMeal;
//   final String dosageInfoQuant;
//   final String time;
//   final String imagePath;
//   final bool showBell;

//   const MedicineCard({
//     Key? key,
//     required this.name,
//     required this.substance,
//     required this.frequency,
//     required this.dosageInfoMeal,
//     required this.dosageInfoQuant,
//     required this.time,
//     required this.imagePath,
//     this.showBell = true,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).textTheme;

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const Medicinedetails(), // ✅ Navigate here
//             ),
//           );
//         },
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
//           padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.asset(
//                   imagePath,
//                   width: 100,
//                   height: 100,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(name, style: theme.titleMedium),
//                     const SizedBox(height: 4),
//                     Text(substance,
//                         style: theme.bodyMedium?.copyWith(
//                           color: Colors.grey,
//                           fontWeight: FontWeight.w500,
//                         )),
//                     const SizedBox(height: 4),
//                     Text(frequency,
//                         style: theme.bodyMedium?.copyWith(
//                           color: Colors.grey,
//                           fontWeight: FontWeight.w500,
//                         )),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         const Icon(Icons.medication_outlined,
//                             color: Colors.grey, size: 16),
//                         const SizedBox(width: 4),
//                         Text(
//                           '$dosageInfoQuant • $dosageInfoMeal',
//                           style: theme.bodySmall?.copyWith(color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         if (showBell)
//                           Icon(Icons.notifications_active,
//                               color: Colors.green.shade600, size: 18),
//                         const SizedBox(width: 6),
//                         Text('كل يوم $time',
//                             style: theme.bodyMedium?.copyWith(
//                               color: Colors.green.shade600,
//                               fontWeight: FontWeight.w700,
//                             )),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
