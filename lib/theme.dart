import 'package:flutter/material.dart';

ThemeData theme() {
  return ThemeData(
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        primary: Color.fromARGB(212, 5, 83, 157),
      ),
      inputDecorationTheme: InputDecorationTheme(),
      textTheme: textTheme());
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    borderSide: BorderSide(
      color: Color.fromARGB(214, 48, 150, 246),
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
    bodyLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 30,
    ),
    bodyMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  );
}

// AppBarTheme appBarTheme() {
//   return AppBarTheme(
//     color: const Color.fromARGB(255, 64, 62, 180),
//     elevation: 0,
//     // iconTheme: IconThemeData(color: Colors.black),
//     titleTextStyle: TextStyle(
//       color: Colors.black,
//       fontSize: 16,
//     ),
//     systemOverlayStyle: SystemUiOverlayStyle.dark,
//   );
// }
