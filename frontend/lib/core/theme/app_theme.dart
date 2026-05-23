import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  static const mint = Color(0xFF2ED3B7);
  static const teal = Color(0xFF0E9384);
  static const navy = Color(0xFF101828);
  static const ink = Color(0xFF1D2939);
  static const cloud = Color(0xFFF7FBFA);
  static const line = Color(0xFFE4E7EC);
  static const danger = Color(0xFFE5484D);
  static const amber = Color(0xFFF79009);
  static const success = Color(0xFF17B26A);
  static const violet = Color(0xFF7A5AF8);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _theme(
    brightness: Brightness.light,
    scaffold: AppColors.cloud,
    surface: Colors.white,
    text: AppColors.navy,
  );

  static ThemeData dark() => _theme(
    brightness: Brightness.dark,
    scaffold: const Color(0xFF071417),
    surface: const Color(0xFF102024),
    text: const Color(0xFFF5FBFA),
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color text,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: brightness,
        primary: AppColors.teal,
        secondary: AppColors.violet,
        error: AppColors.danger,
        surface: surface,
      ),
      scaffoldBackgroundColor: scaffold,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme,
      ).apply(bodyColor: text, displayColor: text),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffold,
        foregroundColor: text,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: brightness == Brightness.light
                ? AppColors.line
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
        ),
      ),
    );
  }
}
