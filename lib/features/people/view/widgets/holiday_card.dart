import 'package:dsv360/features/people/model/holiday.dart';
import 'package:flutter/material.dart';

class HolidayCard extends StatelessWidget {
  final Holiday holiday;

  const HolidayCard({super.key, required this.holiday});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final holidayDate = DateTime.tryParse(holiday.date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isSpent = holidayDate != null && holidayDate.isBefore(today);

    return Opacity(
      opacity: isSpent ? 0.6 : 1.0,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.outline.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSpent
                      ? colors.onSurfaceVariant.withValues(alpha: 0.1)
                      : colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${holiday.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSpent ? colors.onSurfaceVariant : colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  holiday.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSpent ? colors.onSurfaceVariant : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  holiday.location,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
