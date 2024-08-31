import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    primaryContainer: Colors.white,
    secondaryContainer: Colors.grey.shade300,
    tertiaryContainer: Colors.lightBlue.shade200,
    surface: Colors.orange.shade50,
    onSurface: Colors.black,
    error: Colors.red,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleSmall: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      color: Colors.black54,
    ),
    labelMedium: TextStyle(
      fontSize: 12.0,
      color: Colors.black45,
    ),
  ),
);
