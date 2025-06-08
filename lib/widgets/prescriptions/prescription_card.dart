import 'package:flutter/material.dart';
import 'package:hopeless/models/prescription_model.dart';
import 'package:hopeless/screens/prescripitons/edit_prescription_screen.dart';
import 'package:hopeless/services/edit_delete_prescription_service.dart';
import 'package:hopeless/widgets/prescriptions/edit_prescription_modal.dart';

class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  final VoidCallback? onRefresh;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    this.onRefresh,
  });

  String _translateMealRelation(String value) {
    switch (value) {
      case 'with_meal':
        return 'مع الأكل';
      case 'before_meal':
        return 'قبل الأكل';
      case 'mid_meal':
        return 'منتصف الأكل';
      case 'no_relation':
        return 'بدون علاقة';
      case 'empty_stomach':
        return 'على معدة فارغة';
      default:
        return 'غير محدد';
    }
  }

  String _translateDay(String enDay) {
    const map = {
      'Mon': 'الإثنين',
      'Tue': 'الثلاثاء',
      'Wed': 'الأربعاء',
      'Thu': 'الخميس',
      'Fri': 'الجمعة',
      'Sat': 'السبت',
      'Sun': 'الأحد',
    };
    return map[enDay] ?? enDay;
  }

  bool _isEveryday(List<String> days) {
    const fullWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Set.from(days).containsAll(fullWeek);
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              title: const Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.network(
                        prescription.medicineImage,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Image.asset(
                              'assets/images/formentin.png',
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هل تريد حذف الوصفة الخاصة بـ "${prescription.medicineName}"؟',
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.6),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.blueGrey,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('نعم، حذف'),
                ),
              ],
            ),
          ),
    );

    if (confirmed == true) {
      await PrescriptionEditDeleteService.deletePrescription(prescription.id);
      if (onRefresh != null) onRefresh!();
    }
  }

void _openEditDialog(BuildContext context) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditPrescriptionPage(prescription: prescription),
    ),
  );

  // Check if edit was successful
  if (result == true && onRefresh != null) {
    onRefresh!();
  }
}




  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            /// Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Image.network(
                      prescription.medicineImage,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Image.asset(
                            'assets/images/formentin.png',
                            fit: BoxFit.cover,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription.medicineName,
                        style: theme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        prescription.medicineType,
                        style: theme.bodySmall?.copyWith(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prescription.doctor == null ||
                                prescription.doctor!.isEmpty
                            ? 'وصفة شخصية'
                            : 'مسجلة من طرف طبيبي',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (prescription.schedules.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      prescription.schedules
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2FC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${s.horaire.substring(0, 5)} - ${s.posologie} حبة',
                                style: theme.bodySmall,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isEveryday(prescription.frequencyPerWeek)
                        ? 'كل يوم'
                        : 'أيام: ${prescription.frequencyPerWeek.map(_translateDay).join('، ')}',
                    style: theme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.restaurant_menu_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _translateMealRelation(prescription.mealRelation),
                    style: theme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

           if (prescription.doctor == null || prescription.doctor!.isEmpty)
  Align(
    alignment: Alignment.bottomLeft,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconButton(
          Icons.delete_outline,
          Colors.redAccent,
          () => _confirmDelete(context),
        ),
        const SizedBox(width: 10),
        _iconButton(
          Icons.edit_outlined,
          const Color(0xFF4A90E2),
          () => _openEditDialog(context),
        ),
      ],
    ),
  ),

          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color color, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
