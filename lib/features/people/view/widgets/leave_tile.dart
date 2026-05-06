import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/custom_card_button.dart';
import 'package:dsv360/core/widgets/custom_chip.dart';
import 'package:flutter/material.dart';

class LeaveTile extends StatelessWidget {
  final String type;
  final String name;
  final String start;
  final String end;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final bool isAdmin;

  const LeaveTile({
    super.key,
    required this.type,
    required this.name,
    required this.start,
    required this.end,
    required this.status,
    this.onTap,
    this.onEditTap,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withValues(alpha: 1.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CustomChip(
                  label: status,
                  color: customColors.primary!,
                  icon: null,
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey.withValues(alpha: 0.2)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAdmin)
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: customColors.textSecondary,
                        ),
                      ),
                    Text(
                      "From $start",
                      style: TextStyle(
                        fontSize: 14,
                        color: customColors.textSecondary,
                      ),
                    ),
                    Text(
                      "to $end",
                      style: TextStyle(
                        fontSize: 14,
                        color: customColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                child: Row(
                  children: [
                    if ((!IsHaveAccess.instance.isAdmin &&
                            !IsHaveAccess.instance.isManager) &&
                        status.toLowerCase() == "pending")
                      CustomCardButton(icon: Icons.edit, onTap: onEditTap!),
                    const SizedBox(width: 8),
                    CustomCardButton(icon: Icons.remove_red_eye, onTap: onTap!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
