import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/teams/view/widgets/responsive_scale_helper.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║               SEARCH FIELD COMPONENT                        ║
// ╚══════════════════════════════════════════════════════════════╝

class SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final ResponsiveScale rs;

  const SearchField({
    required this.hintText,
    required this.onChanged,
    required this.rs,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final isDark = themeController.themeMode.value == ThemeMode.dark;
    final br = rs.radius(11);
    final border = OutlineInputBorder(
      borderRadius: br,
      borderSide: BorderSide(
        color: customColors.inputBorder ??
            (isDark ? AppColorsDark.inputBorder : AppColorsLight.inputBorder),
        width: 1,
      ),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: br,
      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
    );
    return TextField(
      onChanged: onChanged,
      style: TextStyle(
          fontSize: rs.f(13),
          color: customColors.textPrimary ??
              (isDark
                  ? AppColorsDark.textPrimary
                  : AppColorsLight.textPrimary)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            fontSize: rs.f(13),
            color: customColors.textHint ??
                (isDark ? AppColorsDark.textHint : AppColorsLight.textHint)),
        prefixIcon: Icon(Icons.search_rounded,
            size: rs.s(18),
            color: customColors.textHint ??
                (isDark
                    ? AppColorsDark.textHint
                    : AppColorsLight.textHint)),
        prefixIconConstraints: BoxConstraints(
          minWidth: rs.s(36),
          minHeight: rs.s(36),
        ),
        filled: true,
        fillColor: customColors.inputFill ??
            (isDark ? AppColorsDark.inputFill : AppColorsLight.inputFill),
        contentPadding: EdgeInsets.symmetric(vertical: rs.s(9)),
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        isDense: true,
      ),
    );
  }
}
