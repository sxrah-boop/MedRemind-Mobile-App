import 'package:flutter/material.dart';
import 'package:hopeless/models/history_model.dart';
import 'package:hopeless/services/fetch_history_service.dart';
import 'package:hopeless/widgets/historyCardWidget.dart' show HistoryCard;

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  late Future<List<HistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = HistoryService.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: FutureBuilder<List<HistoryEntry>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد بيانات للجرعات السابقة'));
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children:
                snapshot.data!
                    .map(
                      (entry) => HistoryCard(
                        id: entry.id,
                        prescriptionId: entry.prescriptionId,
                        horaireId: entry.horaireId,
                        medicineName: entry.medicineName,
                        fullName: entry.fullName,
                        imageUrl: entry.imageUrl,
                        posologie: entry.posologie,
                        horaireTime:
                            entry.horaireTime, // ✅ Correct argument name
                        status: entry.status,
                        confirmedAt: entry.confirmedAt,
                      ),
                    )
                    .toList(),
          );
        },
      ),
    );
  }
}
