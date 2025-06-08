import 'package:flutter/material.dart';
import 'package:hopeless/chatbot/chat_screen.dart';

class CustomMenuBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomMenuBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  static const Color micButtonColor = Color(0xFFFDE9C8);
  static const Color micIconColor = Color(0xFF112A54);
  static const Color selectedColor = Color.fromARGB(255, 26, 65, 134);
  static const Color unselectedColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Full bottom background (fills behind gesture area)
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100, // Ensures white background under home bar
              color: Colors.white,
            ),
          ),
        ),

        // Menu bar content (inside SafeArea)
        SafeArea(
          top: false,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.notifications_none,
                  label: 'Rappels',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Education',
                  index: 1,
                ),
                const SizedBox(width: 60), // for the mic button
                _buildNavItem(
                  icon: Icons.medical_services_outlined,
                  label: 'Medicaments',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),

        // Floating mic button
Positioned(
  top: -25,
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    },
    child: Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: micButtonColor,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/chatbot.png', // 👈 Your chatbot image
          fit: BoxFit.cover, // 👈 Makes sure it fills nicely
        ),
      ),
    ),
  ),
),

      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = index == selectedIndex;
    final Color color = isSelected ? selectedColor : unselectedColor;

   return GestureDetector(
  onTap: () => onItemSelected(index),
  child: SizedBox(
    height: 60,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  ),
);

  }
}
