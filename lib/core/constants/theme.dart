import 'package:flutter/material.dart';

class ThemeController {
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

  final ValueNotifier<Color> seedColor = ValueNotifier(
    const Color.fromARGB(255, 255, 0, 0),
  ); // fallback
}

final themeController = ThemeController();

ThemeData buildLightTheme(Color seedColor) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onBackground,
      elevation: 0,
    ),

    cardTheme: CardThemeData(color: colorScheme.surface, elevation: 0),

    textTheme: TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
      ),
      bodySmall: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
    ),
  );
}

ThemeData buildDarkTheme(Color seedColor) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onBackground,
      elevation: 0,
    ),

    cardTheme: CardThemeData(color: colorScheme.surface, elevation: 0),

    textTheme: TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
      ),
      bodySmall: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
    ),
  );
}

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
