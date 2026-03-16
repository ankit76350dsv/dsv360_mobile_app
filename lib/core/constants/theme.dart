import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

extension ThemeDataExtension on ThemeData {
  CustomColors get custom => extension<CustomColors>()!;
}

class ThemeController {
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  final ValueNotifier<Color> seedColor = ValueNotifier(
    const Color(0xFF004da7),
  ); // fallback
}

final themeController = ThemeController();

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? primary;
  final Color? primaryLight;
  final Color? primaryDark;
  final Color? background;
  final Color? cardBackground;
  final Color? surfaceBackground;
  final Color? textPrimary;
  final Color? textSecondary;
  final Color? textHint;
  final Color? inputFill;
  final Color? inputBorder;
  final Color? inputFocused;
  final Color? greyBorder;
  final Color? divider;
  final Color? avatarBackground;
  final Color? statusInProgress;
  final Color? statusCompleted;
  final Color? statusPending;
  final Color? success;
  final Color? textWhite;
  final Color? logoColor;
  final Color? error;
  final Color? tabbarBackground;
  final Color? tabbarIndicator;
  final Color? chatBubbleBot;

  const CustomColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.background,
    required this.cardBackground,
    required this.surfaceBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.inputFill,
    required this.inputBorder,
    required this.inputFocused,
    required this.greyBorder,
    required this.divider,
    required this.avatarBackground,
    required this.statusInProgress,
    required this.statusCompleted,
    required this.statusPending,
    required this.success,
    required this.textWhite,
    required this.logoColor,
    required this.error,
    required this.tabbarBackground,
    required this.tabbarIndicator,
    required this.chatBubbleBot,
  });

  @override
  CustomColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? background,
    Color? cardBackground,
    Color? surfaceBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? inputFill,
    Color? inputBorder,
    Color? inputFocused,
    Color? greyBorder,
    Color? divider,
    Color? avatarBackground,
    Color? statusInProgress,
    Color? statusCompleted,
    Color? statusPending,
    Color? success,
    Color? textWhite,
    Color? logoColor,
    Color? error,
    Color? tabbarBackground,
    Color? tabbarIndicator,
    Color? chatBubbleBot,
  }) {
    return CustomColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      background: background ?? this.background,
      cardBackground: cardBackground ?? this.cardBackground,
      surfaceBackground: surfaceBackground ?? this.surfaceBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocused: inputFocused ?? this.inputFocused,
      greyBorder: greyBorder ?? this.greyBorder,
      divider: divider ?? this.divider,
      avatarBackground: avatarBackground ?? this.avatarBackground,
      statusInProgress: statusInProgress ?? this.statusInProgress,
      statusCompleted: statusCompleted ?? this.statusCompleted,
      statusPending: statusPending ?? this.statusPending,
      success: success ?? this.success,
      textWhite: textWhite ?? this.textWhite,
      logoColor: logoColor ?? this.logoColor,
      error: error ?? this.error,
      tabbarBackground: tabbarBackground ?? this.tabbarBackground,
      tabbarIndicator: tabbarIndicator ?? this.tabbarIndicator,
      chatBubbleBot: chatBubbleBot ?? this.chatBubbleBot,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      primary: Color.lerp(primary, other.primary, t),
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t),
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t),
      background: Color.lerp(background, other.background, t),
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t),
      surfaceBackground: Color.lerp(
        surfaceBackground,
        other.surfaceBackground,
        t,
      ),
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t),
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t),
      textHint: Color.lerp(textHint, other.textHint, t),
      inputFill: Color.lerp(inputFill, other.inputFill, t),
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t),
      inputFocused: Color.lerp(inputFocused, other.inputFocused, t),
      greyBorder: Color.lerp(greyBorder, other.greyBorder, t),
      divider: Color.lerp(divider, other.divider, t),
      avatarBackground: Color.lerp(avatarBackground, other.avatarBackground, t),
      statusInProgress: Color.lerp(statusInProgress, other.statusInProgress, t),
      statusCompleted: Color.lerp(statusCompleted, other.statusCompleted, t),
      statusPending: Color.lerp(statusPending, other.statusPending, t),
      success: Color.lerp(success, other.success, t),
      textWhite: Color.lerp(textWhite, other.textWhite, t),
      logoColor: Color.lerp(logoColor, other.logoColor, t),
      error: Color.lerp(error, other.error, t),
      tabbarBackground: Color.lerp(tabbarBackground, other.tabbarBackground, t),
      tabbarIndicator: Color.lerp(tabbarIndicator, other.tabbarIndicator, t),
      chatBubbleBot: Color.lerp(chatBubbleBot, other.chatBubbleBot, t),
    );
  }
}

ThemeData buildLightTheme(Color seedColor) {
  return ThemeData.light(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: AppColorsLight.background,

    extensions: [
      CustomColors(
        primary: seedColor,
        primaryLight: Color.lerp(seedColor, Colors.white, 0.3),
        primaryDark: Color.lerp(seedColor, Colors.black, 0.3),
        background: AppColorsLight.background,
        cardBackground: AppColorsLight.cardBackground,
        surfaceBackground: AppColorsLight.surfaceBackground,
        textPrimary: AppColorsLight.textPrimary,
        textSecondary: AppColorsLight.textSecondary,
        textHint: AppColorsLight.textHint,
        inputFill: AppColorsLight.inputFill,
        inputBorder: AppColorsLight.inputBorder,
        inputFocused: AppColorsLight.inputFocused,
        greyBorder: AppColorsLight.greyBorder,
        divider: AppColorsLight.divider,
        avatarBackground: AppColorsLight.avatarBackground,
        statusInProgress: AppColorsLight.statusInProgress,
        statusCompleted: AppColorsLight.statusCompleted,
        statusPending: AppColorsLight.statusPending,
        success: AppColorsLight.success,
        textWhite: AppColorsLight.textWhite,
        logoColor: const Color(0xFF004da7),
        error: AppColorsLight.error,
        tabbarBackground: AppColorsLight.tabbarBackground,
        tabbarIndicator: AppColorsLight.tabbarIndicator,
        chatBubbleBot: AppColorsLight.chatBubbleBot,
      ),
    ],

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColorsLight.textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    cardTheme: CardThemeData(
      color: AppColorsLight.cardBackground,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: AppColorsLight.greyBorder.withOpacity(0.2),
          width: 1.5,
        ),
      ),
    ),

    textTheme: TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorsLight.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColorsLight.textPrimary,
      ),
      bodySmall: TextStyle(fontSize: 12, color: AppColorsLight.textSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColorsLight.textPrimary),
      bodyLarge: TextStyle(fontSize: 18, color: AppColorsLight.textSecondary),
      cardTitle: TextStyle(fontSize: 16, color: AppColorsLight.textPrimary, fontWeight: FontWeight.bold)
    ),

    drawerTheme: DrawerThemeData(backgroundColor: AppColorsLight.background),

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
  return ThemeData.dark(useMaterial3: true).copyWith(
    colorScheme: ColorScheme.dark(primary: seedColor),

    scaffoldBackgroundColor: AppColorsDark.background,

    extensions: [
      CustomColors(
        primary: seedColor,
        primaryLight: Color.lerp(seedColor, Colors.white, 0.3),
        primaryDark: Color.lerp(seedColor, Colors.black, 0.3),
        background: AppColorsDark.background,
        cardBackground: AppColorsDark.cardBackground,
        surfaceBackground: AppColorsDark.surfaceBackground,
        textPrimary: AppColorsDark.textPrimary,
        textSecondary: AppColorsDark.textSecondary,
        textHint: AppColorsDark.textHint,
        inputFill: AppColorsDark.inputFill,
        inputBorder: AppColorsDark.inputBorder,
        inputFocused: AppColorsDark.inputFocused,
        greyBorder: AppColorsDark.greyBorder,
        divider: AppColorsDark.divider,
        avatarBackground: AppColorsDark.avatarBackground,
        statusInProgress: AppColorsDark.statusInProgress,
        statusCompleted: AppColorsDark.statusCompleted,
        statusPending: AppColorsDark.statusPending,
        success: AppColorsDark.success,
        textWhite: AppColorsDark.textWhite,
        logoColor: const Color(0xFF1976D2),
        error: AppColorsDark.error,
        tabbarBackground: AppColorsDark.tabbarBackground,
        tabbarIndicator: AppColorsDark.tabbarIndicator,
        chatBubbleBot: AppColorsDark.chatBubbleBot,
      ),
    ],

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColorsDark.textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    cardTheme: CardThemeData(
      color: AppColorsDark.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: AppColorsDark.greyBorder.withOpacity(0.2),
          width: 1.5,
        ),
      ),
    ),

    textTheme: TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorsDark.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColorsDark.textPrimary,
      ),
      bodySmall: TextStyle(fontSize: 12, color: AppColorsDark.textSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColorsDark.textPrimary),
      bodyLarge: TextStyle(fontSize: 18, color: AppColorsDark.textPrimary),
      cardTitle: TextStyle(fontSize: 16, color: AppColorsDark.textPrimary, fontWeight: FontWeight.bold)
    ),

    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF0B0B0D)),

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
