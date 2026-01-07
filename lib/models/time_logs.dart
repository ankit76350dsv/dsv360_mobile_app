class TimeLogs {
  final String dayDate;
  final String username;
  final String checkIn;
  final String checkOut;
  final String totalTime;

  TimeLogs({
    required this.dayDate,
    required this.username,
    required this.checkIn,
    required this.checkOut,
    required this.totalTime,
  });

  factory TimeLogs.fromJson(Map<String, dynamic> json) => TimeLogs(
        dayDate: json['Day_Date']?.toString() ?? '',
        username: json['Username']?.toString() ?? '',
        checkIn: json['Check_In']?.toString() ?? '',
        checkOut: json['Check_Out']?.toString() ?? '',
        totalTime: json['Total_Time']?.toString() ?? '0',
      );

  Map<String, dynamic> toJson() => {
        'Day_Date': dayDate,
        'Username': username,
        'Check_In': checkIn,
        'Check_Out': checkOut,
        'Total_Time': totalTime,
      };

  // Helper methods for display formatting
  String get formattedDayDate => dayDate;
  String get formattedCheckIn => checkIn;
  String get formattedCheckOut => checkOut;
  String get formattedTotalTime => totalTime;
}

