import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData theme() {
  return ThemeData(
    appBarTheme: appBarTheme(),
    fontFamily: 'Inter',
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A73E8),
      primary: const Color(0xFF1A73E8),
      secondary: const Color(0xFF66B2FF),
      tertiary: const Color(0xFF004AAD),
      surface: Colors.white,
      background: const Color(0xFFF8FAFC),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardTheme: cardTheme(),
    inputDecorationTheme: inputDecorationTheme(),
    textTheme: textTheme(),
    elevatedButtonTheme: elevatedButtonsTheme(),
  );
}

CardTheme cardTheme() {
  return CardTheme(
    elevation: 0.5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
    surfaceTintColor: Colors.white,
    shadowColor: Colors.black.withOpacity(0.1),
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(
      color: Colors.grey.shade200,
      width: 1.5,
    ),
  );
  return InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    enabledBorder: outlineInputBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFF1A73E8),
        width: 1.5,
      ),
    ),
    border: outlineInputBorder,
    filled: true,
    fillColor: Colors.white,
    hintStyle: TextStyle(color: Colors.grey.shade500),
  );
}

TextTheme textTheme() {
  return const TextTheme(
    bodyLarge: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      letterSpacing: -0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: -0.2,
    ),
  );
}

ElevatedButtonThemeData elevatedButtonsTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFF1A73E8),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Color(0xFF1A73E8)),
    titleTextStyle: TextStyle(
      color: Color(0xFF1A1A1A),
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );
}
