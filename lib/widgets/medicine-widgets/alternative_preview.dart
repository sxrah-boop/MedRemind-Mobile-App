import 'package:flutter/material.dart';
class AlternativePreview extends StatelessWidget {
  final String? imagePath;
  final String name;
  final String substance;

  const AlternativePreview({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.substance,
  }) : super(key: key);

  bool isNetworkImage(String? path) {
    return path != null && path.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return SizedBox(
      width: 150,
      height: 200, // <-- Fixed height to prevent overflow
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center align
          children: [
            Center(
              child: isNetworkImage(imagePath)
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/images/formentin.png',
                      image: imagePath!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/formentin.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/formentin.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            Text(
              substance,
              textAlign: TextAlign.center,
              style: theme.bodySmall?.copyWith(
                color: Colors.grey,
                fontSize: 12,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
