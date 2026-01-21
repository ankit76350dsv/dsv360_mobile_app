class AttendanceDetail {
  final String dayDate;
  final String username;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String? totalTime; // in minutes

  AttendanceDetail({
    required this.dayDate,
    required this.username,
    required this.checkIn,
    this.checkOut,
    this.totalTime,
  });

  /// Factory constructor to parse API JSON
  factory AttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceDetail(
      dayDate: json['Day_Date']?.toString() ?? '',
      username: json['Username']?.toString() ?? '',
      checkIn: DateTime.parse(json['Check_In']),
      checkOut: json['Check_Out'] != null
          ? DateTime.parse(json['Check_Out'])
          : null,
      totalTime: json['Total_Time']?.toString(),
    );
  }
}
