import 'package:flutter/material.dart';

ThemeData theme() {
  return ThemeData(
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        primary: Color.fromARGB(229, 186, 139, 253),
      ),
      inputDecorationTheme: InputDecorationTheme(),
      textTheme: textTheme());
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    borderSide: BorderSide(
      color: Color.fromARGB(229, 186, 139, 253),
    ),
  );
  return InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      border: outlineInputBorder);
}

TextTheme textTheme() {
  return TextTheme(
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 33,
    ),
    titleMedium: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  );
}
