import 'package:flutter/material.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_text_styles.dart';

class GenericCard extends StatelessWidget {
  final String id;
  final String name;
  final String status;
  final String? subtitleIcon;
  final String? subtitleText; 
  final String dateRange; 
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
    required this.chips,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
      case 'Pending':
        return AppColors.statusPending;
      case 'Work In Process':
      case 'In Progress':
        return AppColors.statusInProgress;
      case 'Completed':
        return AppColors.statusCompleted;
      case 'Closed':
      case 'On Hold':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.greyBorder,
            ),

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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle (Client/Owner)
                        if (subtitleIcon != null && subtitleText != null)
                          Row(
                            children: [
                              Icon(
                                _getIconFromString(subtitleIcon!),
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                subtitleText!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        if (subtitleIcon != null && subtitleText != null)
                          const SizedBox(height: 8),

                        // Dates
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateRange,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
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
                                  child: _buildChip(entry.value),
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
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: AppColors.primary,
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
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete,
                                size: 20,
                                color: AppColors.error,
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

  Widget _buildChip(CardChip chip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: chip.isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: chip.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              chip.icon,
              size: 18,
              color: chip.isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              chip.count,
              style: TextStyle(
                color: chip.isActive ? AppColors.primary : AppColors.textSecondary,
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
  final IconData icon;
  final String count;
  final bool isActive;
  final VoidCallback? onTap;

  CardChip({
    required this.icon,
    required this.count,
    required this.isActive,
    this.onTap,
  });
}
