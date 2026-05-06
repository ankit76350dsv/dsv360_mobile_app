import 'package:flutter/material.dart';
import 'package:dsv360/features/teams/view/widgets/responsive_scale_helper.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║               ICON BUTTON COMPONENT                         ║
// ╚══════════════════════════════════════════════════════════════╝

class IconBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;
  final ResponsiveScale rs;
  final bool isLoading;

  const IconBtn({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
    required this.rs,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: rs.s(32),
        height: rs.s(32),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: rs.radius(8),
        ),
        child: isLoading
            ? SizedBox(
                width: rs.s(12),
                height: rs.s(12),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(iconColor),
                  ),
                ),
              )
            : Icon(icon, size: rs.s(16), color: iconColor),
      ),
    );
  }
}
