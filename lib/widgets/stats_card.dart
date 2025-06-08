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

  @override
  Widget build(BuildContext context) {
    final double percent = taken / total;
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300), // ✅ light grey border
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
                    'بقي $taken/$total من أدوية اليوم',
                    style: theme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800, // extra bold
                      color: Color.fromARGB(255, 44, 44, 44),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لقد شربت $taken أدوية في الوقت، واصل\nاحترام مواعيد الدواء لصحة افضل !',
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
