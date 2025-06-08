import 'package:flutter/material.dart';
import 'package:hopeless/widgets/medicine-widgets/alternative_preview.dart';
import 'package:hopeless/widgets/medicine-widgets/info_pill.dart';

class Medicinedetails extends StatelessWidget {
  const Medicinedetails({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

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
                child: Image.asset(
                  'assets/images/formentin.png',
                  width: 250,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Formentin 1000mg',
                style: theme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Metformine',
                style: theme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Pills
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  InfoPill(icon: Icons.access_time, label: 'كل يوم'),
                  InfoPill(icon: Icons.wb_sunny_outlined, label: 'صباحا'),
                  InfoPill(icon: Icons.restaurant, label: 'بعد الأكل'),
                  InfoPill(icon: Icons.medication_outlined, label: 'حبة واحدة'),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                '''فورمينتين 1000 ملغ هو مضاد حيوي يُستخدم لعلاج الالتهابات البكتيرية مثل التهابات الجهاز التنفسي، التهابات الأذن، والتهابات المسالك البولية. يساعد في قتل البكتيريا المسببة للمرض، لكن يجب أخذه وفقاً لوصفة الطبيب وعدم التوقف عن تناوله قبل انتهاء المدة المحددة حتى لو شعرت بتحسن. إذا كنت تعاني من حساسية تجاه البنسلين، استشر طبيبك قبل استخدامه.''',
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
              SizedBox(
                height: 155,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, index) {
                    return AlternativePreview(
                      imagePath: 'assets/images/formentin.png',
                      name: 'Formentin 1000mg',
                      substance: 'Metformine',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
