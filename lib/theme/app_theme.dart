import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFC98904);
  static const Color darkGold = Color(0xFF8B6508);
  static const Color titleGold = Color(0xFFB47A00);
  static const Color lightGold = Color(0xFFE4CF88);
  static const Color lineGold = Color(0xFFC88A11);
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color inputText = Color(0xFF2F2F2F);
  static const Color background = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFF9B2C2C);
  static const Color errorBackground = Color(0xFFFFF0F0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    fontFamily: 'Arial',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGold,
      primary: primaryGold,
      secondary: darkGold,
      surface: background,
      error: errorRed,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 16, color: textDark),
      bodyMedium: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 14, color: textDark),
      bodySmall: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 12, color: textDark),
      titleLarge: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 28, fontWeight: FontWeight.w900, color: titleGold),
      titleMedium: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 20, fontWeight: FontWeight.w800, color: darkGold),
      titleSmall: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 16, fontWeight: FontWeight.w700, color: darkGold),
      labelLarge: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
      labelMedium: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      labelSmall: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: darkGold,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(inherit: true, fontFamily: 'Arial', fontSize: 20, fontWeight: FontWeight.w800, color: darkGold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: primaryGold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: errorRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: errorRed, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(primaryGold),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        elevation: WidgetStatePropertyAll(0),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 13)),
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            inherit: true,
            fontFamily: 'Arial',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(darkGold),
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            inherit: true,
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Color(0xFFB98212),
      thickness: 1.2,
    ),
  );
}