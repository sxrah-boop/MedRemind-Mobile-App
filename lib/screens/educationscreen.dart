import 'package:flutter/material.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEAF2FC), Color(0xFFF9FAFB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            children: [
              Text(
                'معلومات تهم صحتك',
                style: theme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF112A54),
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 20),
              _educationCard(
                title: 'أهمية تنظيم السكر',
                content:
                    'الحفاظ على مستوى السكر في الدم ضمن المعدل الطبيعي يقلل من خطر المضاعفات مثل أمراض القلب، الكلى، وفقدان البصر.',
              ),
              _educationCard(
                title: 'الحمية المتوازنة',
                content:
                    'اتباع نظام غذائي غني بالألياف وقليل السكريات يساعد في التحكم في مستويات السكر.',
              ),
              _educationCard(
                title: 'مراقبة الجلوكوز',
                content:
                    'افحص نسبة السكر بانتظام وتابع النتائج مع طبيبك لضبط الجرعات.',
              ),
              _educationCard(
                title: 'أخذ الأدوية في وقتها',
                content:
                    'احرص على تناول الدواء في المواعيد المحددة لتجنب ارتفاع أو انخفاض السكر المفاجئ.',
              ),
              _educationCard(
                title: 'ممارسة الرياضة',
                content:
                    'المشي لمدة 30 دقيقة يوميًا يساعد في تحسين حساسية الإنسولين وخفض مستوى السكر.',
              ),
              const SizedBox(height: 24),
              Text(
                'تذكير:',
                style: theme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                'لا تتوقف عن تناول الأدوية أو تغير الجرعة دون استشارة الطبيب، وتأكد من حضور الفحوصات الدورية.',
                style: theme.bodyMedium,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _educationCard({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFEAF2FC)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC5D3EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF112A54),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
