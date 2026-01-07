import 'package:flutter/material.dart';





class AppColors {
  static const primary = Color(0xFF1E6EA7);
  static const accent = Color(0xFF12C6A0);
  static const bg = Color(0xFF0F0F11);
  static const card = Color(0xFF1F1F1F);
  static const surface = Color(0xFF141414);
  static const muted = Color(0xFF9E9E9E);
}

final ColorScheme _appColorScheme = ColorScheme.dark(
  brightness: Brightness.dark,
  primary: AppColors.primary,
  onPrimary: Colors.white,
  secondary: AppColors.accent,
  onSecondary: Colors.black,
  // Use surface for widget backgrounds (cards, sheets, etc.)
  surface: AppColors.surface,
  onSurface: Colors.white,
  // do not set `background` here (deprecated for your use-case)
  error: const Color(0xFFCF6679),
  onError: Colors.black,
);

final ThemeData appTheme = ThemeData.from(
  colorScheme: _appColorScheme,
  textTheme: Typography.whiteMountainView, // choose an appropriate textTheme
).copyWith(
  // scaffoldBackgroundColor still OK — this controls Scaffold specifically
  scaffoldBackgroundColor: AppColors.bg,
  appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  useMaterial3: false, // Material 2 look; set to true if you want M3 styles
);



