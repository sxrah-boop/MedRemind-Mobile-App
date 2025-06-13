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
    
    // Custom colors to match the main theme
    const primaryColor = Color(0xFF112A54);
    const surfaceColor = Color(0xFFE5E7EB);
    const surfaceVariant = Color(0xFFD1D5DB);
    const onSurfaceVariant = Color(0xFF6B7280);

    return Container(
      width: 160,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: surfaceVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image container with better styling
          Container(
            width: double.infinity,
            height: 120,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: surfaceVariant.withOpacity(0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: isNetworkImage(imagePath)
                    ? FadeInImage.assetNetwork(
                        placeholder: 'assets/images/formentin.png',
                        image: imagePath!,
                        fit: BoxFit.contain,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.medication,
                            color: onSurfaceVariant,
                            size: 40,
                          );
                        },
                      )
                    : imagePath != null
                        ? Image.asset(
                            'assets/images/formentin.png',
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.medication,
                            color: onSurfaceVariant,
                            size: 40,
                          ),
              ),
            ),
          ),
          
          // Text content with better spacing and styling
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Medicine name
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Substance with pill styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 231, 242, 251).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      substance,
                      textAlign: TextAlign.center,
                      style: theme.bodySmall?.copyWith(
                        color: onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}