import 'package:flutter/material.dart';
import 'package:hopeless/models/prescription_model.dart';
import 'package:hopeless/screens/prescripitons/edit_prescription_screen.dart';
import 'package:hopeless/services/edit_delete_prescription_service.dart';
import 'package:hopeless/screens/medicine-screens/medicine_details_screen.dart';

class PrescriptionCard extends StatefulWidget {
  final Prescription prescription;
  final VoidCallback? onRefresh;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    this.onRefresh,
  });

  @override
  State<PrescriptionCard> createState() => _PrescriptionCardState();
}

class _PrescriptionCardState extends State<PrescriptionCard> {
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
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              title: const Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF112A54),
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'هل تريد حذف الوصفة الخاصة بـ "${widget.prescription.medicineName}"؟',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      height: 1.6,
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.all(20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'نعم، حذف',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );

    if (confirmed == true) {
      await PrescriptionEditDeleteService.deletePrescription(
        widget.prescription.id,
      );
      if (widget.onRefresh != null) widget.onRefresh!();
    }
  }

  void _openEditDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPrescriptionPage(prescription: widget.prescription),
      ),
    );

    if (result == true && widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE5E7EB).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => Medicinedetails(prescription: widget.prescription),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicine Image
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFF8FAFC),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.prescription.medicineImage.toString(),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Image.asset(
                                  'assets/images/formentin.png',
                                  fit: BoxFit.cover,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Medicine Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.prescription.medicineName} ${widget.prescription.medicineDosage}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF112A54),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.prescription.medicineDci,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.prescription.doctor == null ||
                                            widget.prescription.doctor!.isEmpty
                                        ? const Color(0xFFEFF6FF)
                                        : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.prescription.doctor == null ||
                                        widget.prescription.doctor!.isEmpty
                                    ? 'وصفة شخصية'
                                    : 'وصفة طبية',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      widget.prescription.doctor == null ||
                                              widget
                                                  .prescription
                                                  .doctor!
                                                  .isEmpty
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Schedule Pills
                  if (widget.prescription.schedules.isNotEmpty) ...[
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.prescription.schedules.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final schedule = widget.prescription.schedules[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF112A54).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF112A54).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: const Color(
                                    0xFF112A54,
                                  ).withOpacity(0.8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${schedule.horaire.substring(0, 5)} • ${schedule.posologie == 1 ? 'حبة واحدة' : '${schedule.posologie} حبات'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(
                                      0xFF112A54,
                                    ).withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Info Row
                  Column(
                    children: [
                      // Days Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isEveryday(widget.prescription.frequencyPerWeek)
                                  ? 'كل يوم'
                                  : widget.prescription.frequencyPerWeek
                                      .map(_translateDay)
                                      .join('، '),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Meal Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _translateMealRelation(
                                widget.prescription.mealRelation,
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Action Buttons (only for personal prescriptions)
                  if (widget.prescription.doctor == null ||
                      widget.prescription.doctor!.isEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActionButton(
                          icon: Icons.delete_outline_rounded,
                          color: Colors.red,
                          onPressed: () => _confirmDelete(context),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          color: const Color(0xFF112A54),
                          onPressed: () => _openEditDialog(context),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
