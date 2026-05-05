import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/core/widgets/custom_chip.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/features/people/repositories/holiday_repository.dart';
import 'package:dsv360/features/people/view/widgets/holiday_month_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HolidayCalendarPage extends ConsumerWidget {
  const HolidayCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).custom;
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
        title: const Text(
          'Holiday Calendar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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

          final Map<String, List> groupedHolidays = {};
          for (var h in filteredHolidays) {
            groupedHolidays.putIfAbsent(h.month, () => []).add(h);
          }

          final months = groupedHolidays.keys.toList();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Holidays grouped month-wise',
                        style: TextStyle(
                          color: customColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  CustomChip(
                    label: 'Remaining: $remaining / $total',
                    color: customColors.primary!,
                    icon: null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              ...months.map((month) {
                final monthHolidays = groupedHolidays[month]!;
                return HolidayMonthSection(
                  month: month,
                  holidays: List.from(monthHolidays),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
