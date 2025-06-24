import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StatsCard extends StatelessWidget {
  final int taken;
  final int total;

  const StatsCard({
    Key? key,
    required this.taken,
    required this.total,
  }) : super(key: key);

String _arabicDoseText(int count) {
  if (count == 0) return '0 جرعة';
  if (count == 1) return 'جرعة واحدة';
  if (count == 2) return 'جرعتين';
  if (count >= 3 && count <= 10) return '$count جرعات';
  return '$count جرعة'; // fallback for 11+
}
String _arabicDoseCount(int count) {
  if (count == 0) return '0 جرعة';
  if (count == 1) return 'جرعة واحدة';
  if (count == 2) return 'جرعتين';
  if (count >= 3 && count <= 10) return '$count جرعات';
  return '$count جرعة'; // fallback for 11+
}
  @override
  Widget build(BuildContext context) {
    final int remaining = total - taken;
    final double percent = total > 0 ? taken / total : 0.0;
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            // Circular indicator
            CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 9.0,
              percent: percent.clamp(0.0, 1.0),
              animation: true,
              backgroundColor: Colors.grey.shade200,
              progressColor: Colors.green,
              circularStrokeCap: CircularStrokeCap.round,
              center: Text(
                '$taken/$total',
                style: theme.titleMedium?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Right text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
  'تبقّى ${_arabicDoseCount(remaining)} من أصل ${_arabicDoseCount(total)} لليوم',
  style: theme.titleMedium?.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: const Color.fromARGB(255, 44, 44, 44),
  ),
),
                  const SizedBox(height: 8),
                  Text(
  'أحسنت! لقد تناولت ${_arabicDoseText(taken)}، واصل الالتزام\nبمواعيدك الدوائية لتحافظ على صحتك .',
  style: theme.bodySmall?.copyWith(
    color: Colors.grey.shade600,
    height: 1.5,
  ),
  textAlign: TextAlign.right,
),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}