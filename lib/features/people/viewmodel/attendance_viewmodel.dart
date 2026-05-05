import 'package:flutter_riverpod/flutter_riverpod.dart';

const List<String> attendancePeriodOptions = [
  'This Week',
  'Previous Week',
  'This Month',
  'Last Month',
];

// Selected period label for the attendance date range selector
final attendancePeriodProvider =
    StateProvider.autoDispose<String>((ref) => 'This Week');

// Computes (startDate, endDate) from the selected period label
(DateTime, DateTime) getAttendanceDateRange(String selected) {
  final now = DateTime.now();
  DateTime start;
  DateTime end;

  if (selected == 'This Week') {
    final daysToSubtract = now.weekday % 7;
    start = now.subtract(Duration(days: daysToSubtract));
    end = start.add(const Duration(days: 6));
  } else if (selected == 'Previous Week') {
    final daysToSubtract = (now.weekday % 7) + 7;
    start = now.subtract(Duration(days: daysToSubtract));
    end = start.add(const Duration(days: 6));
  } else if (selected == 'This Month') {
    start = DateTime(now.year, now.month, 1);
    end = DateTime(now.year, now.month + 1, 0);
  } else if (selected == 'Last Month') {
    start = DateTime(now.year, now.month - 1, 1);
    end = DateTime(now.year, now.month, 0);
  } else {
    start = now;
    end = now;
  }

  return (
    DateTime(start.year, start.month, start.day),
    DateTime(end.year, end.month, end.day),
  );
}
