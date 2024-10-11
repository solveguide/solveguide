import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    primaryContainer: Colors.white,
    secondaryContainer: const Color.fromARGB(255, 224, 224, 224),
    tertiaryContainer: const Color.fromARGB(255, 129, 212, 250),
    surface: Colors.orange.shade50,
    error: Colors.red,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.black54,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      color: Colors.black45,
    ),
  ),
);
