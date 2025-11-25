// lib/widgets/tag_chip.dart
import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  final double borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final Widget? leading;

  const TagChip({
    Key? key,
    required this.label,
    this.gradientColors = const [Color(0xFF6EE7B7), Color(0xFF3B82F6)],
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
    this.borderRadius = 24.0,
    this.elevation = 6.0,
    this.onTap,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 13,
      shadows: [
        Shadow(
          offset: Offset(0, 0.5),
          blurRadius: 0.5,
          color: Colors.black26,
        )
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: elevation,
                offset: Offset(0, elevation / 3),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: 8),
              ],
              Text(
                label,
                style: textStyle ?? defaultStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
