import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/teams/view/widgets/dashed_border_painter.dart';
import 'package:dsv360/features/teams/view/widgets/responsive_scale_helper.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║               EMPTY DROP ZONE COMPONENT                     ║
// ╚══════════════════════════════════════════════════════════════╝

class EmptyDropZone extends StatelessWidget {
  final ResponsiveScale rs;
  const EmptyDropZone({super.key, required this.rs});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final isDark = themeController.themeMode.value == ThemeMode.dark;
    final borderColor = customColors.inputBorder ??
        (isDark ? AppColorsDark.inputBorder : AppColorsLight.inputBorder);
    final textColor = customColors.textHint ??
        (isDark ? AppColorsDark.textHint : AppColorsLight.textHint);

    return Padding(
      padding: rs.sym(v: 8),
      child: CustomPaint(
        painter: DashedBorderPainter(color: borderColor),
        child: SizedBox(
          height: rs.s(100),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_with_rounded,
                  color: textColor, size: rs.s(22)),
              SizedBox(height: rs.s(6)),
              Text(
                'Drag and Drop here',
                style: TextStyle(
                  color: textColor,
                  fontSize: rs.f(12.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
