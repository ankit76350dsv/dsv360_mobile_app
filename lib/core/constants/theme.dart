import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeController {
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  final ValueNotifier<Color> seedColor = ValueNotifier(
    const Color.fromARGB(255, 220, 146, 18),
  ); // fallback
}

final themeController = ThemeController();

ThemeData buildLightTheme(Color seedColor) {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    colorScheme: ColorScheme(
      brightness: Brightness.light,

      // 🔹 Neutral UI
      background: Colors.white,
      surface: Colors.white,
      onBackground: Colors.black,
      onSurface: Colors.black,

      // 🔹 Accent only
      primary: seedColor,
      onPrimary: Colors.white,
      secondary: seedColor.withOpacity(0.8),
      onSecondary: Colors.white,

      error: Colors.red,
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: Color(0xFFf6f6f6),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    cardTheme: const CardThemeData(color: Colors.white, elevation: 0),

    textTheme: const TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black,
        // fontWeight: FontWeight.w700,
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? seedColor : Colors.grey,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? seedColor.withOpacity(0.3)
            : Colors.grey.withOpacity(0.3),
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? seedColor.withOpacity(0.5)
            : Colors.grey,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: seedColor,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData buildDarkTheme(Color seedColor) {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    colorScheme: ColorScheme(
      brightness: Brightness.dark,

      // 🔹 Neutral UI
      background: Colors.black,
      surface: const Color(0xFF121212),
      onBackground: Colors.white,
      onSurface: Colors.white,

      // 🔹 Accent only
      primary: seedColor,
      onPrimary: Colors.black,
      secondary: seedColor.withOpacity(0.8),
      onSecondary: Colors.black,
      tertiary: Color(0xFF121212),

      error: Colors.red,
      onError: Colors.black,
    ),

    scaffoldBackgroundColor: const Color(0xFF0B0B0D),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    cardTheme: const CardThemeData(
      color: Color.fromARGB(255, 27, 28, 29),
      elevation: 0,
    ),

    textTheme: const TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodySmall: TextStyle(fontSize: 12, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? seedColor : Colors.grey,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? seedColor.withOpacity(0.3)
            : Colors.grey.withOpacity(0.3),
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? seedColor.withOpacity(0.5)
            : Colors.grey,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: seedColor,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
