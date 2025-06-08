import 'package:flutter/material.dart';
import 'package:hopeless/models/prescription_model.dart';
import 'package:hopeless/services/list_prescriptions_service_api.dart';

import 'package:hopeless/widgets/prescriptions/prescription_card.dart';

class DailyMedList extends StatefulWidget {
  const DailyMedList({super.key});

  @override
  State<DailyMedList> createState() => _DailyMedListState();
}
class _DailyMedListState extends State<DailyMedList> {
  late Future<List<Prescription>> _futurePrescriptions;

  @override
  void initState() {
    super.initState();
    _refreshPrescriptions();
  }

 void _refreshPrescriptions() {
  debugPrint('[🔄 Fetching updated prescriptions]');
  setState(() {
    _futurePrescriptions = PrescriptionService.fetchPrescriptions();
  });
}

  String _todayKey() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[now.weekday - 1];
  }

  bool _shouldShowToday(Prescription p) {
    return p.frequencyPerWeek.contains(_todayKey()) || p.frequencyPerWeek.length == 7;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: FutureBuilder<List<Prescription>>(
        future: _futurePrescriptions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ في جلب الأدوية: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد أدوية حالياً'));
          }

          final filtered = snapshot.data!.where(_shouldShowToday).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'أدوية اليوم',
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...filtered.map((p) => PrescriptionCard(
                  prescription: p,
                  onRefresh: _refreshPrescriptions, // ✅ Add refresh
                )).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
