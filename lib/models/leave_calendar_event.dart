class LeaveCalendarEvent {
  final String username;
  final String leaveType;
  final String startDate;
  final String endDate;

  LeaveCalendarEvent({
    required this.username,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
  });

  factory LeaveCalendarEvent.fromJson(Map<String, dynamic> json) {
    return LeaveCalendarEvent(
      username: json['Username']?.toString() ?? '',
      leaveType: json['Leave_Type']?.toString() ?? '',
      startDate: json['Start_Date']?.toString() ?? '',
      endDate: json['End_Date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Username': username,
      'Leave_Type': leaveType,
      'Start_Date': startDate,
      'End_Date': endDate,
    };
  }
}
