import 'package:flutter/material.dart';
import 'package:hopeless/models/prescription_model.dart';
import 'package:hopeless/screens/history/history.dart';
import 'package:hopeless/screens/prescripitons/Make_prescription_screen.dart';
import 'package:hopeless/services/list_prescriptions_service_api.dart';
import 'package:hopeless/widgets/prescriptions/prescription_card.dart';
import 'package:hopeless/widgets/medicine-widgets/add_medicine_button.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  bool _showCurrent = true;
  List<Prescription> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    try {
      final result = await PrescriptionService.fetchPrescriptions();
      setState(() => _prescriptions = result);
    } catch (e) {
      print('❌ Error loading prescriptions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF2FC),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildToggleBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showCurrent ? 'أدويتي' : 'الجرعات السابقة',
                      style: theme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    AddMedicineButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MakePrescriptionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _showCurrent
                    ? ListView(
                        padding: const EdgeInsets.only(bottom: 80),
                        children: _buildCurrentList(),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(bottom: 80),
                        child: HistoryList(), // ✅ FIXED: used directly in Expanded
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showCurrent = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showCurrent ? const Color(0xFFE1EAFB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'أدويتي',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showCurrent = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showCurrent ? const Color(0xFFE1EAFB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'الجرعات السابقة',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCurrentList() {
    final activePrescriptions = _prescriptions
        .where((prescription) => prescription.status == 'active')
        .toList();

    if (activePrescriptions.isEmpty) {
      return [const Center(child: Text("لا توجد وصفات حالياً"))];
    }

    return activePrescriptions
        .map((prescription) => PrescriptionCard(
              prescription: prescription,
              onRefresh: _loadPrescriptions,
            ))
        .toList();
  }
}
