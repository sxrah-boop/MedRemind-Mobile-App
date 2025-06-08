// import 'package:flutter/material.dart';
// import 'package:hopeless/services/search_med_api.dart';
// import 'package:hopeless/widgets/search-widgets/search_results.dart';


// class SearchMedicineScreen extends StatefulWidget {
//   const SearchMedicineScreen({super.key});

//   @override
//   State<SearchMedicineScreen> createState() => _SearchMedicineScreenState();
// }

// class _SearchMedicineScreenState extends State<SearchMedicineScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> _results = [];
//   Map<String, dynamic>? _selectedMedicine;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }

//   void _onSearchChanged() {
//     final query = _searchController.text.trim();
//     MedicineApi.search(query).then((data) {
//       if (mounted) {
//         setState(() => _results = data);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("ابحث عن دواء"),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 1,
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'اسم الدواء أو المادة الفعالة',
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//               ),
//             ),
//             Expanded(
//   child: _selectedMedicine == null
//       ? MedicineResultList(
//           results: _results,
//           onSelect: (med) => setState(() => _selectedMedicine = med),
//         )
//      : SearchThenMedInfoScreen(medicine: _selectedMedicine!),

// ),

//           ],
//         ),
//       ),
//     );
//   }
// }
