import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkScheduleCard extends StatelessWidget {
  final String weekRange;

  const WorkScheduleCard({super.key, required this.weekRange});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: Colors.blueAccent, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  'Work Schedule',
                  style: TextStyle(
                    color: customColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(weekRange, style: TextStyle(color: customColors.textSecondary)),
            const SizedBox(height: 16),
            const Text(
              'General',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final date = startOfWeek.add(Duration(days: index));
                final isToday = date.isAtSameMomentAs(today);
                final dayName = DateFormat('E').format(date);
                final isWeekend = date.weekday == 6 || date.weekday == 7;

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          color: customColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isToday ? customColors.primary : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isToday)
                        Column(
                          children: [
                            Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 10,
                                color: customColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2,
                              width: 20,
                              decoration: BoxDecoration(
                                color: customColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        )
                      else if (isWeekend)
                        Text(
                          'Weekend',
                          style: TextStyle(
                            fontSize: 10,
                            color: customColors.textSecondary,
                          ),
                        )
                      else
                        const SizedBox(height: 18),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
