import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF0A7EA4);
  static const bg = Color(0xFFF5F7FA);
  static const lightBlue = Color(0xFFE0F2FB);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.black87,
    ),
  );

  static ButtonStyle get pillFilled => FilledButton.styleFrom(
    backgroundColor: primary,
    minimumSize: const Size.fromHeight(48),
    shape: const StadiumBorder(),
  );

  static ButtonStyle get pillOutlined => OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: const BorderSide(color: primary),
    minimumSize: const Size.fromHeight(44),
    shape: const StadiumBorder(),
  );
}