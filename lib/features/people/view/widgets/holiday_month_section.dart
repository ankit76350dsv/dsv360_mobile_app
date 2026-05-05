import 'package:dsv360/features/people/model/holiday.dart';
import 'package:dsv360/features/people/view/widgets/holiday_card.dart';
import 'package:flutter/material.dart';

class HolidayMonthSection extends StatelessWidget {
  final String month;
  final List<Holiday> holidays;

  const HolidayMonthSection({
    super.key,
    required this.month,
    required this.holidays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
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
        ...holidays.map((h) => HolidayCard(holiday: h)),
        const SizedBox(height: 16),
      ],
    );
  }
}
