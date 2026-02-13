import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class GenericCard extends StatelessWidget {
  final String id;
  final String name;
  final String status;
  final String? subtitleIcon;
  final String? subtitleText;
  final String dateRange;
  final String? dueDate;
  final List<CardChip> chips;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const GenericCard({
    super.key,
    required this.id,
    required this.name,
    required this.status,
    this.subtitleIcon,
    this.subtitleText,
    required this.dateRange,
    this.dueDate,
    required this.chips,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  Color _getStatusColor(String status, BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    switch (status) {
      case 'Open':
      case 'Pending':
        return customColors.statusPending!;
      case 'Work In Process':
      case 'In Progress':
        return customColors.statusInProgress!;
      case 'Completed':
        return customColors.statusCompleted!;
      case 'Closed':
      case 'On Hold':
        return customColors.error!;
      default:
        return customColors.textSecondary!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: customColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ID and Status
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: customColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      id,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status, context).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status, context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(height: 1, thickness: 1, color: customColors.greyBorder),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          name,
                          style: TextStyle(
                            color: customColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Subtitle (Client/Owner)
                        if (subtitleIcon != null && subtitleText != null)
                          Row(
                            children: [
                              Icon(
                                _getIconFromString(subtitleIcon!),
                                size: 18,
                                color: customColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  subtitleText!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: customColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (subtitleIcon != null && subtitleText != null)
                          const SizedBox(height: 8),

                        // Dates
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: customColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateRange,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: customColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (dueDate != null) const SizedBox(height: 8),
                        if (dueDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.event_outlined,
                                size: 18,
                                color: customColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dueDate!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: customColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // Stats Row
                        Row(
                          children: chips
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(
                                    right: entry.key < chips.length - 1 ? 8 : 0,
                                  ),
                                  child: _buildChip(entry.value, context),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  // Action Icons
                  if (onEdit != null || onDelete != null)
                    Row(
                      children: [
                        if (onEdit != null)
                          InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                              color: customColors.primary!.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color:  customColors.primary,
                              ),
                            ),
                          ),
                        if (onEdit != null && onDelete != null)
                          const SizedBox(width: 8),
                        if (onDelete != null)
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: customColors.error!.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete,
                                size: 20,
                                color: customColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(CardChip chip, BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    // If label is provided, render as label badge
    if (chip.label != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: chip.onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                chip.backgroundColor?.withValues(alpha: 0.15) ??
                customColors.primary!.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: chip.backgroundColor ?? customColors.primary!,
              width: 1,
            ),
          ),
          child: Text(
            chip.label!,
            style: TextStyle(
              color: chip.backgroundColor ?? customColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    // Otherwise render as icon with count
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: chip.onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: chip.isActive
              ? customColors.primary!.withValues(alpha: 0.1)
              : customColors.textSecondary!.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chip.icon != null)
              Icon(
                chip.icon,
                size: 18,
                color: chip.isActive
                    ? customColors.primary
                    : customColors.textSecondary,
              ),
            if (chip.icon != null) const SizedBox(width: 8),
            if (chip.count != null)
              Text(
                chip.count!,
                style: TextStyle(
                  color: chip.isActive
                      ? customColors.primary
                      : customColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'business':
        return Icons.business;
      case 'person':
        return Icons.person;
      default:
        return Icons.business;
    }
  }
}

class CardChip {
  final IconData? icon;
  final String? count;
  final String? label;
  final bool isActive;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  CardChip({
    this.icon,
    this.count,
    this.label,
    required this.isActive,
    this.backgroundColor,
    this.onTap,
  });
}
