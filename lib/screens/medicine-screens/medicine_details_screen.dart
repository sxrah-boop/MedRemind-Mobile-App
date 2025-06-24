import 'package:flutter/material.dart';
import 'package:hopeless/models/prescription_model.dart';
import 'package:hopeless/services/alternatives_fetch_service.dart';
import 'package:hopeless/widgets/medicine-widgets/alternative_preview.dart';
import 'package:hopeless/widgets/medicine-widgets/info_pill.dart';

class Medicinedetails extends StatefulWidget {
  final Prescription prescription;

  const Medicinedetails({super.key, required this.prescription});

  @override
  State<Medicinedetails> createState() => _MedicinedetailsState();
}

class _MedicinedetailsState extends State<Medicinedetails> {
  late Future<List<Map<String, dynamic>>> alternatives;

  @override
  void initState() {
    super.initState();
    alternatives = AlternativesService.fetchAlternatives(
      widget.prescription.medicineId,
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final prescription = widget.prescription;
    
    // Custom color scheme
    const primaryColor = Color(0xFF112A54);
    const surfaceColor = Color.fromARGB(255, 255, 255, 255);
    const onSurface = Color(0xFF112A54);
    const surfaceVariant = Color.fromARGB(255, 222, 235, 255);
    const onSurfaceVariant = Color.fromARGB(255, 222, 235, 255);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: surfaceColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: onSurface),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section with image and basic info
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Medicine image with enhanced styling
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        
                        border: Border.all(
                          color: surfaceVariant,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Image.network(
                            prescription.medicineImage.toString(),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                color: surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/formentin.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Medicine name and dosage
                    Text(
                      "${prescription.medicineName} ${prescription.medicineDosage}",
                      style: theme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // DCI with better styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        prescription.medicineDci,
                        style: theme.bodyMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Content section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info pills section with title
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'معلومات الجرعة',
                          style: theme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Enhanced info pills
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: [
                        InfoPill(
                          icon: Icons.calendar_today_outlined,
                          label: prescription.frequencyPerWeek
                              .map(_translateDay)
                              .join('، '),
                        ),
                        if (prescription.schedules.isNotEmpty)
                          ...prescription.schedules.map(
                            (schedule) => InfoPill(
                              icon: Icons.access_time,
                              label:
                                  '${schedule.horaire.substring(0, 5)} - ${schedule.posologie} حبة',
                            ),
                          ),
                        InfoPill(
                          icon: Icons.restaurant,
                          label: _translateMealRelation(prescription.mealRelation),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Instructions section
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'التعليمات',
                          style: theme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Instructions with better container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: surfaceVariant,
                        ),
                      ),
                      child: Text(
                        prescription.instructions.isNotEmpty
                            ? prescription.instructions
                            : 'لا توجد تعليمات محددة.',
                        style: theme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: onSurface,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Alternatives section
                    Row(
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'البدائل المتاحة',
                          style: theme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Alternatives list
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: alternatives,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'جاري تحميل البدائل...',
                                    style: theme.bodyMedium?.copyWith(
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade600,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'فشل في تحميل البدائل',
                                    style: theme.bodyMedium?.copyWith(
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    color: onSurfaceVariant,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لا توجد بدائل متاحة حالياً',
                                    style: theme.bodyMedium?.copyWith(
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final alternativesList = snapshot.data!;

                        return SizedBox(
                          height: 240,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: alternativesList.length,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (_, index) {
                              final alt = alternativesList[index];
                              final imageUrl =
                                  (alt['image'] != null &&
                                          alt['image'].toString().isNotEmpty)
                                      ? alt['image']
                                      : null;

                              return AlternativePreview(
                                imagePath: imageUrl,
                                name: alt['brand_name'] ?? '',
                                substance: alt['dci'] ?? '',
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}