import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/models/holiday.dart';
import 'package:dsv360/repositories/holiday_repository.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HolidayCalendarPage extends ConsumerWidget {
  const HolidayCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final holidayAsync = ref.watch(holidayRepositoryProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holiday Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: holidayAsync.when(
        loading: () => const GlobalLoader(message: 'Loading holidays...'),
        error: (err, stack) => GlobalError(
          message: 'Failed to load holidays: $err',
          onRetry: () => ref.refresh(holidayRepositoryProvider),
        ),
        data: (holidays) {
          final filteredHolidays = holidays
              .where((h) => h.location == selectedLocation)
              .toList();

          // Group by month
          final Map<String, List<Holiday>> groupedHolidays = {};
          for (var h in filteredHolidays) {
            groupedHolidays.putIfAbsent(h.month, () => []).add(h);
          }

          final months = groupedHolidays.keys.toList();

          // Calculate remaining holidays
          final now = DateTime.now();
          final remaining = filteredHolidays.where((h) {
            final date = DateTime.tryParse(h.date);
            return date != null &&
                (date.isAfter(now) || date.isAtSameMomentAs(now));
          }).length;
          final total = filteredHolidays.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Holiday Calendar',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Holidays grouped month-wise',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Remaining: $remaining / $total',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location Dropdown
              CustomDropDownField(
                options: const [
                  DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                  DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedLocationProvider.notifier).state = value;
                  }
                },
                labelText: 'Location',
                hintText: 'Select Location',
                selectedOption: selectedLocation,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),

              // Holiday List
              ...months.map((month) {
                final monthHolidays = groupedHolidays[month]!;
                return _MonthSection(month: month, holidays: monthHolidays);
              }),
            ],
          );
        },
      ),
    );
  }
}

class _MonthSection extends StatelessWidget {
  final String month;
  final List<Holiday> holidays;

  const _MonthSection({required this.month, required this.holidays});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: colors.primary, width: 4)),
          ),
          width: double.infinity,
          child: Text(
            month,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...holidays.map((h) => _HolidayCard(holiday: h)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HolidayCard extends StatelessWidget {
  final Holiday holiday;

  const _HolidayCard({required this.holiday});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Date Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${holiday.day}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name
            Expanded(
              child: Text(
                holiday.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Location Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
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
    );
  }
}
