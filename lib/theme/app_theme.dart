import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    color: Color(0xFF555162),
    foregroundColor: Colors.white
  ),
  scaffoldBackgroundColor: const Color(0xFF262432),
  cardTheme: const CardTheme(
    color: Color(0xFF393647),
    shadowColor: Color(0xFF555162),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
        color: Colors.white
    ),
  ),
  hintColor: Colors.white,
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.white
    ),
    prefixIconColor: Colors.yellow[300]
  )
);