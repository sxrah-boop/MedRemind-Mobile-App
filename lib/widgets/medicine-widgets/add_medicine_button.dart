import 'package:flutter/material.dart';

class AddMedicineButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddMedicineButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0xFF112A54),
        );

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, color: Color(0xFF112A54)),
      label: Text(
        'إضافة دواء',
        style: textStyle,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        side: const BorderSide(color: Color(0xFF112A54), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
