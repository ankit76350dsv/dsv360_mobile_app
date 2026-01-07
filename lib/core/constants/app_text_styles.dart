import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Page Title
  static const TextStyle pageTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Card Title
  static const TextStyle cardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Email Text
  static const TextStyle emailText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Input Label
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Input Hint
  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );

  // Status Badge
  static const TextStyle statusBadge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  // Date Text
  static const TextStyle dateText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Upload Text
  static const TextStyle uploadText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}
