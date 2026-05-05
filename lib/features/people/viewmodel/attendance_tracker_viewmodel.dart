import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceTrackerState {
  final String? selectedEmployeeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? queryUserId;
  final String? queryStartDate;
  final String? queryEndDate;

  const AttendanceTrackerState({
    this.selectedEmployeeId,
    this.startDate,
    this.endDate,
    this.queryUserId,
    this.queryStartDate,
    this.queryEndDate,
  });

  AttendanceTrackerState copyWith({
    String? selectedEmployeeId,
    DateTime? startDate,
    DateTime? endDate,
    String? queryUserId,
    String? queryStartDate,
    String? queryEndDate,
  }) {
    return AttendanceTrackerState(
      selectedEmployeeId: selectedEmployeeId ?? this.selectedEmployeeId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      queryUserId: queryUserId ?? this.queryUserId,
      queryStartDate: queryStartDate ?? this.queryStartDate,
      queryEndDate: queryEndDate ?? this.queryEndDate,
    );
  }
}

class AttendanceTrackerNotifier
    extends AutoDisposeNotifier<AttendanceTrackerState> {
  @override
  AttendanceTrackerState build() => const AttendanceTrackerState();

  void selectEmployee(String? employeeId) {
    state = state.copyWith(selectedEmployeeId: employeeId);
  }

  void pickStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
  }

  void pickEndDate(DateTime date) {
    state = state.copyWith(endDate: date);
  }

  // Commits the current selection to trigger a query
  void submitQuery(String startDateFormatted, String endDateFormatted) {
    state = state.copyWith(
      queryUserId: state.selectedEmployeeId,
      queryStartDate: startDateFormatted,
      queryEndDate: endDateFormatted,
    );
  }
}

final attendanceTrackerProvider = AutoDisposeNotifierProvider<
  AttendanceTrackerNotifier,
  AttendanceTrackerState
>(AttendanceTrackerNotifier.new);
