import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF818CF8); // Soft Indigo
  static const Color secondaryColor = Color(0xFF2DD4BF); // Teal
  static const Color backgroundColor = Color(0xFF020617); // Extra Dark Indigo
  static const Color surfaceColor = Color(0xFF0F172A);
  static const Color errorColor = Color(0xFFF87171);

  static final TextTheme textTheme = GoogleFonts.lexendTextTheme(
    ThemeData.dark().textTheme,
  ).copyWith(
    bodyLarge: GoogleFonts.outfit(color: Colors.white),
    bodyMedium: GoogleFonts.outfit(color: Colors.white70),
    bodySmall: GoogleFonts.outfit(color: Colors.white60),
    titleLarge: GoogleFonts.lexend(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
    titleMedium: GoogleFonts.lexend(
        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
    displayLarge: GoogleFonts.lexend(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
  );

  static final TextTheme lightTextTheme = GoogleFonts.outfitTextTheme(
    ThemeData.light().textTheme,
  ).copyWith(
    bodyLarge: GoogleFonts.outfit(color: const Color(0xFF1E293B)), // Slate 800
    bodyMedium: GoogleFonts.outfit(color: const Color(0xFF334155)), // Slate 700
    bodySmall: GoogleFonts.outfit(color: const Color(0xFF475569)), // Slate 600
    titleLarge: GoogleFonts.lexend(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
        fontSize: 28),
    titleMedium: GoogleFonts.lexend(
        color: const Color(0xFF1E293B),
        fontWeight: FontWeight.w600,
        fontSize: 18),
    displayLarge: GoogleFonts.lexend(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
        fontSize: 32),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      error: errorColor,
      onSurface: Color(0xFF0F172A), // Slate 900
    ),
    textTheme: lightTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
          color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9), // Slate 100
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)), // Slate 300
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: const TextStyle(color: Color(0xFF64748B)), // Slate 500
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
    ),
  );
}

// Glassmorphism Utilities
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.color = Colors.white,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
