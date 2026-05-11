import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core palette — dark charcoal grey + maroon
  static const Color bgDeep = Color(0xFF0e0e0e);
  static const Color bgGrey = Color(0xFF161616);
  static const Color bgGreyMid = Color(0xFF1c1c1c);
  static const Color bgMaroon = Color(0xFF1e0f14);

  // Accent — vivid pink-red
  static const Color accentStart = Color(0xFFFF2D55);
  static const Color accentMid = Color(0xFFE8234B);
  static const Color accentEnd = Color(0xFFC41E3A);

  // Text
  static const Color textPrimary = Color(0xFFF0EDEE);
  static const Color textSecondary = Color(0x80F0EDEE); // 50% opacity
  static const Color textAccent = Color(0xFFFF2D55);

  // Shadows
  static const List<BoxShadow> shadowBtn = [
    BoxShadow(
      color: Color(0x59FF2D55), // 35% opacity
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x2EFF2D55), // 18% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowBtnHover = [
    BoxShadow(
      color: Color(0x80FF2D55), // 50% opacity
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x40FF2D55), // 25% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      primaryColor: accentStart,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.02,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.01,
        ),
        titleMedium: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
