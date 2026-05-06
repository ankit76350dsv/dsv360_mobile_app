class AttendanceDashboardEntry {
  final String dayDate;
  final String username;
  final String checkIn;
  final String checkOut;
  final String totalTime;

  AttendanceDashboardEntry({
    required this.dayDate,
    required this.username,
    required this.checkIn,
    required this.checkOut,
    required this.totalTime,
  });

  /// Factory constructor to parse API JSON
  factory AttendanceDashboardEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceDashboardEntry(
      dayDate: json['Day_Date']?.toString() ?? '',
      username: json['Username']?.toString() ?? '',
      checkIn: json['Check_In']?.toString() ?? '',
      checkOut: json['Check_Out']?.toString() ?? '',
      totalTime: json['Total_Time']?.toString() ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Day_Date': dayDate,
      'Username': username,
      'Check_In': checkIn,
      'Check_Out': checkOut,
      'Total_Time': totalTime,
    };
  }
}

class AttendanceDashboardResponse {
  final bool success;
  final String message;
  final List<AttendanceDashboardEntry> data;

  AttendanceDashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  /// Factory constructor to parse API JSON
  factory AttendanceDashboardResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    
    return AttendanceDashboardResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: dataList
          .map((entry) => AttendanceDashboardEntry.fromJson(entry))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((entry) => entry.toJson()).toList(),
    };
  }
}
