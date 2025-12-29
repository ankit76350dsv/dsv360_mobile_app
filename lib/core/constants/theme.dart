import 'package:flutter/material.dart';

/// Global theme mode controller used by the app to switch
/// between light and dark themes.
final ValueNotifier<ThemeMode> appThemeModeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.dark,
);

class AppColors {
  static const primary = Color(0xFF1E6EA7);
  static const accent = Color(0xFF12C6A0);
  static const bg = Color(0xFF0F0F11);
  static const card = Color(0xFF1F1F1F);
  static const surface = Color(0xFF141414);
  static const muted = Color(0xFF9E9E9E);
  static const success = Color(0xFF1db01f);
  static const successDark = Color.fromARGB(255, 18, 107, 19);
}

final ThemeData darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: AppColors.bg,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: AppColors.bg,
    surface: AppColors.card,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    backgroundColor: Colors.transparent,
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.muted),
  ),
);

final ThemeData lightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: Colors.white,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black87,
    onSurface: Colors.black87,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    backgroundColor: Colors.transparent,
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    // headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    // bodyText2: TextStyle(fontSize: 14),
    // subtitle1: TextStyle(fontSize: 16),
    bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
  ),
);
