class AttendanceDetail {
  final String dayDate;
  final String username;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String? totalTime;

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

  /// Convert back to JSON (if needed)
  Map<String, dynamic> toJson() => {
        'Day_Date': dayDate,
        'Username': username,
        'Check_In': checkIn.toIso8601String(),
        'Check_Out': checkOut?.toIso8601String(),
        'Total_Time': totalTime,
      };

  // ------------------
  // Helper getters (UI friendly)
  // ------------------

  bool get isCheckedOut => checkOut != null;

  String get formattedCheckIn =>
      _formatDateTime(checkIn);

  String get formattedCheckOut =>
      checkOut != null ? _formatDateTime(checkOut!) : '—';

  String get formattedTotalTime =>
      totalTime ?? 'In Progress';

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
