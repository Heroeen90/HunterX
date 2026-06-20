import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceVariant = Color(0xFF1C2539);
  static const Color primary = Color(0xFF00FF88);
  static const Color primaryDark = Color(0xFF00CC6A);
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color accent = Color(0xFFFF3D57);
  static const Color warning = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color muted = Color(0xFF555555);
  static const Color error = Color(0xFFFF1744);
  static const Color border = Color(0xFF1E293B);
  static const Color terminalGreen = Color(0xFF00FF88);
  static const Color terminalBg = Color(0xFF050A0E);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          error: accent,
          surface: surface,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: textPrimary,
        ),
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(
          const TextTheme(
            displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
            displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
            titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
            titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
            bodyLarge: TextStyle(color: textPrimary, fontSize: 14),
            bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
            labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: surface,
          selectedIconTheme: IconThemeData(color: primary),
          unselectedIconTheme: IconThemeData(color: textSecondary),
          selectedLabelTextStyle: TextStyle(color: primary, fontSize: 12),
          unselectedLabelTextStyle: TextStyle(color: textSecondary, fontSize: 12),
          indicatorColor: Color(0x2200FF88),
        ),
        cardTheme: CardTheme(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        dividerTheme: const DividerThemeData(color: border),
        iconTheme: const IconThemeData(color: textSecondary),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceVariant,
          selectedColor: const Color(0x2200FF88),
          labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      );

  // Helper method for darkTheme alias
  static ThemeData get darkTheme => dark;
}
