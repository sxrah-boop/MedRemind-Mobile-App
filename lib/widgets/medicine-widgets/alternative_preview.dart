import 'package:flutter/material.dart';

class AlternativePreview extends StatelessWidget {
  final String imagePath;
  final String name;
  final String substance;

  const AlternativePreview({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.substance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      width: 150,
   
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Image.asset(imagePath, width: 100)),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: theme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            substance,
            style: theme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
