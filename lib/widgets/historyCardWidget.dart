import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class HistoryCard extends StatelessWidget {
  final int id;
  final int prescriptionId;
  final int horaireId;
  final String medicineName;
  final String fullName;
  final String imageUrl;
  final int posologie;
  final String horaireTime;
  final String status;
  final String confirmedAt;

  const HistoryCard({
    super.key,
    required this.id,
    required this.prescriptionId,
    required this.horaireId,
    required this.medicineName,
    required this.fullName,
    required this.imageUrl,
    required this.posologie,
    required this.horaireTime,
    required this.status,
    required this.confirmedAt,
  });

  String _formatDose(int dose) {
    return dose == 1 ? 'حبة واحدة' : '$dose حبات';
  }

String _formatConfirmationTime(String timestamp) {
  try {
    final dt = DateTime.parse(timestamp).toLocal();
    final dayName = DateFormat.EEEE('ar').format(dt);     // e.g. الثلاثاء
    final dayNumber = DateFormat.d('ar').format(dt);      // e.g. 24
    final month = algerianMonths[dt.month] ?? '';
    final timeStr = DateFormat('HH:mm').format(dt);       // e.g. 15:30

    return 'تم أخذ الجرعة يوم $dayName، $dayNumber $month على الساعة $timeStr';
  } catch (e) {
    debugPrint('⚠️ Error parsing timestamp: $e');
    return 'تم أخذ الجرعة';
  }
}

  Color _statusColor(String statut) {
    switch (statut) {
      case 'taken':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String statut) {
    switch (statut) {
      case 'taken':
        return 'تم في الوقت';
      case 'late':
        return 'متأخرة';
      case 'missed':
        return 'فائتة';
      default:
        return 'غير معروف';
    }
  }

  
static const algerianMonths = {
  1: 'جانفي',
  2: 'فيفري',
  3: 'مارس',
  4: 'أفريل',
  5: 'ماي',
  6: 'جوان',
  7: 'جويلية',
  8: 'أوت',
  9: 'سبتمبر',
 10: 'أكتوبر',
 11: 'نوفمبر',
 12: 'ديسمبر',
};
  @override
  Widget build(BuildContext context) {
    return Directionality(
textDirection: TextDirection.rtl,

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/formentin.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('الجرعة: ${_formatDose(posologie)}'),
                  Text('الوقت المحدد: $horaireTime'),
                  Text(_formatConfirmationTime(confirmedAt)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor(status)),
              ),
              child: Text(
                _statusText(status),
                style: TextStyle(
                  color: _statusColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
