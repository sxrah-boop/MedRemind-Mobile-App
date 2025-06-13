import 'package:flutter/material.dart';
import 'package:hopeless/screens/scheduled_notifications_screen.dart'; // 👈 Make sure this is your file path

class HomeHeader extends StatelessWidget {
  final String username;

  const HomeHeader({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 18, right: 20, left: 20, bottom: 10),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Greeting Texts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلام $username،',
                  style: theme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'وشراك اليوم؟',
                  style: theme.titleMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            // Notification icon + label
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduledNotificationsScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: OutlinedButton.icon(
  onPressed: () {
    // Navigate to your reminders screen here
        Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduledNotificationsScreen(),
                  ),
                );
  },
  icon: const Icon(
    Icons.notifications_none,
    size: 22,
    color: Color.fromARGB(255, 6, 53, 128),
  ),
  label: const Text(
    'تذكيراتي',
    style: TextStyle(
      color: Color.fromARGB(255, 6, 53, 128),
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
  ),
  style: OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    side: const BorderSide(color: Color.fromARGB(255, 6, 53, 128), width: 1.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  ),
)
            ),
          ],
        ),
      ),
    );
  }
}