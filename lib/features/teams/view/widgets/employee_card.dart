import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/teams/viewmodel/teams_viewmodel.dart';
import 'package:dsv360/features/teams/view/widgets/responsive_scale_helper.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║               EMPLOYEE CARD COMPONENT                       ║
// ╚══════════════════════════════════════════════════════════════╝

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isGrid;
  final ResponsiveScale rs;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.rs,
    this.isGrid = false,
  });

  Widget _buildAvatarImage(double avatarRadius) {
    final imageUrl = employee.profileImageUrl?.trim();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: avatarRadius * 2,
          height: avatarRadius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/profile.jpg',
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              fit: BoxFit.cover,
            );
          },
        ),
      );
    }

    return ClipOval(
      child: Image.asset(
        'assets/images/profile.jpg',
        width: avatarRadius * 2,
        height: avatarRadius * 2,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _cardContent(BuildContext context,
      {double? width, bool elevated = false}) {
    final customColors = Theme.of(context).custom;
    final isDark = themeController.themeMode.value == ThemeMode.dark;
    final avatarRadius = rs.s(isGrid ? 15.0 : 19.0);
    final hPad = rs.s(isGrid ? 8.0 : 12.0);
    final vPad = rs.s(isGrid ? 3 : 10.0);

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: customColors.surfaceBackground ??
            customColors.cardBackground ??
            (isDark
                ? AppColorsDark.surfaceBackground
                : AppColorsLight.surfaceBackground),
        borderRadius: rs.radius(12),
        border: Border.all(
          color: customColors.greyBorder ??
              (isDark ? AppColorsDark.greyBorder : AppColorsLight.greyBorder),
          width: 1,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: rs.s(12),
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: rs.s(4),
                  offset: const Offset(0, 1),
                )
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile avatar
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: customColors.avatarBackground ??
                (isDark
                    ? const Color.fromARGB(255, 96, 96, 96)
                    : const Color.fromARGB(255, 164, 164, 164)),
            child: _buildAvatarImage(avatarRadius),
          ),
          SizedBox(width: rs.s(isGrid ? 6.0 : 10.0)),
          // Name + phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  employee.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: rs.f(isGrid ? 11.5 : 13.5),
                    color: customColors.textPrimary ??
                        (isDark
                            ? AppColorsDark.textPrimary
                            : AppColorsLight.textPrimary),
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: rs.s(1)),
                Text(
                  employee.phone.isNotEmpty ? employee.phone : "No Phone ",
                  style: TextStyle(
                    fontSize: rs.f(isGrid ? 9.5 : 11.0),
                    color: customColors.textSecondary ??
                        (isDark
                            ? AppColorsDark.textSecondary
                            : AppColorsLight.textSecondary),
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          // Drag handle — omitted in grid to save horizontal space
          if (!isGrid)
            Padding(
              padding: EdgeInsets.only(left: rs.s(6)),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: customColors.textHint ??
                    (isDark
                        ? AppColorsDark.textHint
                        : AppColorsLight.textHint),
                size: rs.s(20),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool didPulseDuringDrag = false;

    return LongPressDraggable<Employee>(
      data: employee,
      delay: const Duration(milliseconds: 200),
      hapticFeedbackOnStart: true,
      onDragStarted: () {
        didPulseDuringDrag = false;
        HapticFeedback.heavyImpact();
      },
      onDragUpdate: (_) {
        if (!didPulseDuringDrag) {
          didPulseDuringDrag = true;
          HapticFeedback.mediumImpact();
        }
      },
      onDragEnd: (_) {
        HapticFeedback.lightImpact();
      },
      onDraggableCanceled: (_, __) {
        HapticFeedback.mediumImpact();
      },
      feedback: Material(
        color: Colors.transparent,
        child: _cardContent(context, width: rs.s(250), elevated: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: _cardContent(context),
      ),
      child: Padding(
        // Grid spacing is handled by gridDelegate; list needs explicit gap
        padding: EdgeInsets.only(bottom: isGrid ? 0 : rs.s(8)),
        child: _cardContent(context),
      ),
    );
  }
}
