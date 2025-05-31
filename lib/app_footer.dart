
import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final int currentYear = DateTime.now().year;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0), // Added more bottom padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20, // Adjust size as needed
            height: 20, // Adjust size as needed
            child: Image.asset(
              'assets/logo.png', // logo image
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if logo fails to load
                return Icon(Icons.translate, size: 20, color: colorScheme.onSurface.withOpacity(0.6));
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '© $currentYear Fast Translator App. All rights reserved.', // Updated app name
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}