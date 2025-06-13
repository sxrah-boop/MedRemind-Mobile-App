import 'package:flutter/material.dart';

class InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoPill({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
       color: Color.fromARGB(248, 235, 243, 255),
        borderRadius: BorderRadius.circular(12),
     
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF112A54)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 23, 49, 109),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
