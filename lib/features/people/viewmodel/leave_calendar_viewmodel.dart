import 'package:dsv360/features/people/model/leave_calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveCalendarState {
  final int? selectedDay;
  final List<LeaveCalendarEvent>? selectedLeaves;

  const LeaveCalendarState({this.selectedDay, this.selectedLeaves});

  LeaveCalendarState copyWith({
    int? selectedDay,
    List<LeaveCalendarEvent>? selectedLeaves,
  }) {
    return LeaveCalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      selectedLeaves: selectedLeaves ?? this.selectedLeaves,
    );
  }
}

class LeaveCalendarNotifier
    extends AutoDisposeNotifier<LeaveCalendarState> {
  @override
  LeaveCalendarState build() => const LeaveCalendarState();

  void selectDay(int day, List<LeaveCalendarEvent> leaves) {
    state = state.copyWith(selectedDay: day, selectedLeaves: leaves);
  }
}

final leaveCalendarViewModelProvider = AutoDisposeNotifierProvider<
  LeaveCalendarNotifier,
  LeaveCalendarState
>(LeaveCalendarNotifier.new);

// Determines leave color based on leave type string
Color getLeaveColor(String type) {
  final typeLower = type.toLowerCase();
  if (typeLower.contains('sick')) return const Color(0xFFFACC15);
  if (typeLower.contains('paid')) return const Color(0xFF2DD4BF);
  if (typeLower.contains('unpaid')) return const Color(0xFFF87171);
  return const Color(0xFF94A3B8);
}

// Builds a map of day → leave events for the current month
Map<int, List<LeaveCalendarEvent>> buildMonthLeaveMap(
  List<LeaveCalendarEvent> calendarEvents,
  int year,
  int month,
) {
  final Map<int, List<LeaveCalendarEvent>> mappedLeaves = {};
  for (var item in calendarEvents) {
    final start = DateTime.tryParse(item.startDate);
    final end = DateTime.tryParse(item.endDate);
    if (start == null || end == null) continue;

    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0);

    if (end.isBefore(monthStart) || start.isAfter(monthEnd)) continue;

    var current = start.isBefore(monthStart) ? monthStart : start;
    final loopEnd = end.isAfter(monthEnd) ? monthEnd : end;

    while (
      current.isBefore(loopEnd) || current.isAtSameMomentAs(loopEnd)
    ) {
      if (current.month == month && current.year == year) {
        mappedLeaves.putIfAbsent(current.day, () => []).add(item);
      }
      current = current.add(const Duration(days: 1));
    }
  }
  return mappedLeaves;
}
