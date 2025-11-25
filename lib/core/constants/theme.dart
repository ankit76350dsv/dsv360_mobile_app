import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1E6EA7);
  static const accent = Color(0xFF12C6A0);
  static const bg = Color(0xFF0F0F11);
  static const card = Color(0xFF1F1F1F);
  static const surface = Color(0xFF141414);
  static const muted = Color(0xFF9E9E9E);
}

final ThemeData appTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: AppColors.bg,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: AppColors.bg,
    surface: AppColors.card,
  ),
  appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  textTheme: const TextTheme(
    // headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    // bodyText2: TextStyle(fontSize: 14),
    // subtitle1: TextStyle(fontSize: 16),
  ),
);
