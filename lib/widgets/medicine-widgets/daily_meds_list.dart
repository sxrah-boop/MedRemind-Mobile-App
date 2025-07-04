// import 'package:flutter/material.dart';
// import 'package:hopeless/models/prescription_model.dart';
// import 'package:hopeless/services/list_prescriptions_service_api.dart';

// import 'package:hopeless/widgets/prescriptions/prescription_card.dart';

// class DailyMedList extends StatefulWidget {
//   const DailyMedList({super.key});

//   @override
//   State<DailyMedList> createState() => _DailyMedListState();
// }
// class _DailyMedListState extends State<DailyMedList> {
//   late Future<List<Prescription>> _futurePrescriptions;

//   @override
//   void initState() {
//     super.initState();
//     _refreshPrescriptions();
//   }

//  void _refreshPrescriptions() {
//   debugPrint('[🔄 Fetching updated prescriptions]');
//   setState(() {
//     _futurePrescriptions = PrescriptionService.fetchPrescriptions();
//   });
// }

//   String _todayKey() {
//     final now = DateTime.now();
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[now.weekday - 1];
//   }

//   bool _shouldShowToday(Prescription p) {
//     return p.frequencyPerWeek.contains(_todayKey()) || p.frequencyPerWeek.length == 7;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).textTheme;

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: FutureBuilder<List<Prescription>>(
//         future: _futurePrescriptions,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('حدث خطأ في جلب الأدوية: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('لا توجد أدوية حالياً'));
//           }

//           final filtered = snapshot.data!.where(_shouldShowToday).toList();

//           return SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                   child: Text(
//                     'أدوية اليوم',
//                     style: theme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 ...filtered.map((p) => PrescriptionCard(
//                   prescription: p,
//                   onRefresh: _refreshPrescriptions, // ✅ Add refresh
//                 )).toList(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hopeless/models/prescription_model.dart';
import 'package:hopeless/notification-reminders/notification_service.dart';
import 'package:hopeless/services/list_prescriptions_service_api.dart';
import 'package:hopeless/widgets/prescriptions/prescription_card.dart';

class DailyMedList extends StatefulWidget {
  const DailyMedList({super.key});

  @override
  State<DailyMedList> createState() => _DailyMedListState();
}

class _DailyMedListState extends State<DailyMedList> {
  late Future<List<Prescription>> _futurePrescriptions;
  final Set<int> _alreadyScheduled = {}; // Avoid double scheduling

  @override
  void initState() {
    super.initState();
    _refreshPrescriptions();
  }

  void _refreshPrescriptions() {
    debugPrint('[🔄 Fetching updated prescriptions]');
    final todayKey = _todayKey();

    setState(() {
      _futurePrescriptions = PrescriptionService.fetchPrescriptions().then((prescriptions) async {
        final todayPrescriptions = prescriptions
            .where((p) =>
                p.frequencyPerWeek.contains(todayKey) ||
                p.frequencyPerWeek.length == 7)
            .toList();

        for (final prescription in todayPrescriptions) {
          if (_isDoctorPrescription(prescription) && !_alreadyScheduled.contains(prescription.id)) {
            debugPrint('[🔔 Auto scheduling for doctor prescription ID: ${prescription.id}]');
            _alreadyScheduled.add(prescription.id);
            await NotificationService.syncAndScheduleNotifications(prescription.id);
          }
        }

        return prescriptions;
      });
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

  bool _isDoctorPrescription(Prescription prescription) {
    return prescription.doctor != null && prescription.doctor!.isNotEmpty;
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
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ في جلب الأدوية',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _refreshPrescriptions,
                      child: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('لا توجد أدوية حالياً'),
                ],
              ),
            );
          }

          final filtered = snapshot.data!.where(_shouldShowToday).toList();
          final doctorPrescriptions = filtered.where(_isDoctorPrescription).toList();

          if (filtered.isEmpty) {
            return SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('لا توجد أدوية لهذا اليوم'),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'أدوية اليوم',
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              // Prescriptions List - Fixed height with scrollable content
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  minHeight: 100,
                ),
                child: RefreshIndicator(
                  onRefresh: () async => _refreshPrescriptions(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final prescription = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PrescriptionCard(
                              prescription: prescription,
                              onRefresh: _refreshPrescriptions,
                            ),
                            
                              
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

            ],
          );
        },
      ),
    );
  }
}