import 'package:flutter/material.dart';

class MedicineResultList extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final void Function(Map<String, dynamic>) onSelect;

  const MedicineResultList({
    super.key,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, index) {
        final med = results[index];
        return ListTile(
          title: Text(med['brand_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(med['dci']),
          onTap: () => onSelect(med),
          leading: const Icon(Icons.medical_services_outlined),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }
}
