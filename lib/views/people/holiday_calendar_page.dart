import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/models/holiday.dart';
import 'package:dsv360/repositories/holiday_repository.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
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
        toolbarHeight: 35.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Holiday Calendar',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // if needed can add the icon as well here
        // hook for info action
        // you can open a dialog or screen here
        actions: [],
      ),
      body: holidayAsync.when(
        loading: () => const GlobalLoader(message: 'Loading holidays...'),
        error: (err, stack) => GlobalError(
          message: 'This should never occur',
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
          final today = DateTime(now.year, now.month, now.day);
          final remaining = filteredHolidays.where((h) {
            final date = DateTime.tryParse(h.date);
            return date != null && !date.isBefore(today);
          }).length;
          final total = filteredHolidays.length;

          final locations = holidays.map((h) => h.location).toSet().toList()
            ..sort();

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
                        'Holidays grouped month-wise',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  CustomChip(
                    label: 'Remaining: $remaining / $total',
                    color: colors.primary,
                    icon: null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location Dropdown
              CustomDropDownField(
                options: locations.map((loc) {
                  return DropdownMenuItem(value: loc, child: Text(loc));
                }).toList(),
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
        Card(
          margin: EdgeInsets.symmetric(
            horizontal: 0.0,
            vertical: 8.0,
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border(
                left: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            width: double.infinity,
            child: Text(
              month,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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

    final holidayDate = DateTime.tryParse(holiday.date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Consider it spent if it's before today
    final isSpent = holidayDate != null && holidayDate.isBefore(today);

    return Opacity(
      opacity: isSpent ? 0.6 : 1.0,
      child: Card(
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
                  color: isSpent
                      ? colors.onSurfaceVariant.withOpacity(0.1)
                      : colors.primaryContainer.withOpacity(0.3),
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

              // Name
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

              // Location Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
      ),
    );
  }
}
