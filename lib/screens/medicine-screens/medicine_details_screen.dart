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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    prescription.medicineImage.toString(),
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Image.asset(
                          'assets/images/formentin.png',
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                  "${widget.prescription.medicineName} ${widget.prescription.medicineDosage}" ,
                style: theme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                prescription.medicineDci,
                style: theme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
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

              const SizedBox(height: 24),

              // Description
              Text(
                prescription.instructions.isNotEmpty
                    ? prescription.instructions
                    : 'لا توجد تعليمات محددة.',
                style: theme.bodyMedium?.copyWith(height: 1.8),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 24),

              // Alternatives title
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'البدائل',
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Alternatives horizontal list
              FutureBuilder<List<Map<String, dynamic>>>(
                future: alternatives,
                builder: (context, snapshot) {
                  print(
                    '📦 Snapshot Connection State: ${snapshot.connectionState}',
                  );
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print('⏳ Waiting for alternatives to load...');
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print('❌ Error fetching alternatives: ${snapshot.error}');
                    return Center(child: Text('فشل في تحميل البدائل'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print('⚠️ No alternatives found or data empty.');
                    return Center(child: Text('لا توجد بدائل متاحة'));
                  }

                  final alternativesList = snapshot.data!;
                  print('✅ Alternatives fetched: ${alternativesList.length}');

                  return SizedBox(
                    height: 220, // <- Set height properly to fit the cards
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: alternativesList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        final alt = alternativesList[index];
                        print(
                          '🖼️ Alt ${index + 1}: ${alt['brand_name']} - ${alt['image']}',
                        );

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
            ],
          ),
        ),
      ),
    );
  }
}
