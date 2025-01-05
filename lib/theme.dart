import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData theme() {
  return ThemeData(
    appBarTheme: appBarTheme(),
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue.shade800,
      primary: Colors.blue.shade500,
      secondary: Colors.blue.shade300,
      tertiary: Colors.blue.shade900,
    ),
    inputDecorationTheme: inputDecorationTheme(),
    textTheme: textTheme(),
    elevatedButtonTheme: elevatedButtonsTheme(),
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    borderSide: BorderSide(
      color: Colors.blue.shade300,
    ),
  );
  return InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    border: outlineInputBorder,
    filled: true,
  );
}

TextTheme textTheme() {
  return TextTheme(
    bodyLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    bodyMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  );
}

ElevatedButtonThemeData elevatedButtonsTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    elevation: 0,
    // iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 16,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );
}
