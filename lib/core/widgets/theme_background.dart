import 'package:flutter/material.dart';
import 'package:genx_bill/core/theme/app_theme.dart';

class ThemeBackground extends StatelessWidget {
  final Widget child;
  const ThemeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E1B4B), // Deep Indigo
                  AppTheme.backgroundColor,
                ]
              : [
                  const Color(0xFFE0E7FF), // Very light Indigo
                  const Color(0xFFF8FAFC), // Slate 50
                ],
          center: Alignment.topLeft,
          radius: 1.5,
        ),
      ),
      child: child,
    );
  }
}
