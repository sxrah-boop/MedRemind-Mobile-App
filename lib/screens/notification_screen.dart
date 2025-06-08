import 'package:flutter/material.dart';
import 'package:hopeless/notification-reminders/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  final Map<String, String> payload;

  const NotificationScreen({super.key, required this.payload});

  String _translateMeal(String? relation) {
    switch (relation) {
      case 'before_meal':
        return 'قبل الأكل';
      case 'with_meal':
        return 'مع الأكل';
      case 'after_meal':
        return 'بعد الأكل';
      case 'mid_meal':
        return 'منتصف الأكل';
      case 'empty_stomach':
        return 'على معدة فارغة';
      default:
        return 'بدون تحديد';
    }
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 28,
            color: const Color(0xFF003496), // dark blue
          ),
          const SizedBox(width: 12),
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = payload['medicineName'] ?? 'دواء غير معروف';
    final dose = payload['dose'] ?? '';
    final time = payload['horaire'] ?? '';
    final instructions = payload['instructions'] ?? '';
    final image = payload['image'] ?? 'https://via.placeholder.com/64';
    final meal = _translateMeal(payload['mealRelation']);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: const Text(
              'تذكير الدواء',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: const Color(0xFF112A54),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    image,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(Icons.medical_services, size: 64),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24),
              if (dose.isNotEmpty)
                _infoTile(
                  icon: Icons.medication,
                  label: 'الجرعة',
                  value: dose == '1' ? 'حبة واحدة' : '$dose حبات',
                ),

              if (time.isNotEmpty)
                _infoTile(
                  icon: Icons.access_time,
                  label: 'الساعة',
                  value: time.length >= 5 ? time.substring(0, 5) : time,
                ),
              _infoTile(
                icon: Icons.restaurant,
                label: 'علاقة الجرعة مع الوجبات:',
                value: meal,
              ),
              if (instructions.isNotEmpty)
                _infoTile(
                  icon: Icons.info_outline,
                  label: 'تعليمات إضافية',
                  value: instructions,
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF112A54), // Your primary blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    // For "Taken" button
                    onPressed: () async {
                      await NotificationService.handleDoseConfirmation(
                        horaireId: int.parse(payload['horaireId']!),
                        scheduledTimeStr: payload['horaire']!,
                        notificationId: int.parse(
                          payload['notificationId']!,
                        ), // ✅ FIXED
                        context: context,
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (_) => false,
                      );
                    },

                    child: const Text(
                      'نعم قمت بأخذ الدواء',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.black87,
                    ),
                    // For "Remind Me Later" button
                    onPressed: () async {
                      await NotificationService.scheduleRemindLaterNotification(
                        payload,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⏰ سيتم تذكيرك مرة أخرى بعد 10 دقائق'),
                        ),
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (_) => false,
                      );
                    },

                    child: const Text(
                      'ذكرني مرة أخرى بعد عشرة دقائق',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
