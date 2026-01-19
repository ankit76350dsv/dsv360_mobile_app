import 'package:flutter/material.dart';

// ==================== THEME SELECTOR ====================

// typedef AppColors = AppColorsDark;  
typedef AppColors = AppColorsLight;  


// ==================== DARK THEME COLORS ====================
class AppColorsDark {
  // Primary Colors
  static const Color primary = Color(0xFF1976D2); // Blue
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);
  
  // Background - Dark Theme
  static const Color background = Color(0xFF121212); // Dark background
  static const Color cardBackground = Color(0xFF1E1E1E); // Dark card
  static const Color surfaceBackground = Color(0xFF2C2C2C); // Surface
  
  // Text Colors - Dark Theme
  static const Color textPrimary = Color(0xFFFFFFFF); // White text
  static const Color textSecondary = Color(0xFFB0B0B0); // Light gray
  static const Color textHint = Color(0xFF757575); // Darker gray
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color statusInProgress = Color(0xFFFF9800); // Orange
  static const Color statusCompleted = Color(0xFF4CAF50); // Green
  static const Color statusPending = Color(0xFFFFC107); // Amber
  
  // Input Fields - Dark Theme
  static const Color inputBorder = Color(0xFF424242);
  static const Color inputFill = Color(0xFF2C2C2C); // Dark input background
  static const Color inputFocused = Color(0xFF4CAF50);
  static const Color greyBorder = Color(0xFF616161); // Grey border for cards
  
  // Error
  static const Color error = Color(0xFFEF5350);
  
  // Divider
  static const Color divider = Color(0xFF424242);
  
  // Avatar Background
  static const Color avatarBackground = Color(0xFF4CAF50);
}

// ==================== LIGHT THEME COLORS ====================
class AppColorsLight {
  // Primary Colors
  static const Color primary = Color(0xFF1976D2); // Blue
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);
  
  // Background - Light Theme
  static const Color background = Color(0xFFF5F5F5); // Light gray background
  static const Color cardBackground = Color(0xFFFFFFFF); // White card
  static const Color surfaceBackground = Color(0xFFFFFFFF); // White surface
  
  // Text Colors - Light Theme
  static const Color textPrimary = Color(0xFF000000); // Black text
  static const Color textSecondary = Color(0xFF757575); // Gray
  static const Color textHint = Color(0xFF9E9E9E); // Light gray
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color statusInProgress = Color(0xFFFF9800); // Orange
  static const Color statusCompleted = Color(0xFF4CAF50); // Green
  static const Color statusPending = Color(0xFFFFC107); // Amber
  
  // Input Fields - Light Theme
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFill = Color(0xFFF5F5F5); // Light input background
  static const Color inputFocused = Color(0xFF4CAF50);
  static const Color greyBorder = Color(0xFFBDBDBD); // Grey border for cards
  
  // Error
  static const Color error = Color(0xFFD32F2F);
  
  // Divider
  static const Color divider = Color(0xFFE0E0E0);
  
  // Avatar Background
  static const Color avatarBackground = Color(0xFF4CAF50);
}
