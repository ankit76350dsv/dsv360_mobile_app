class LeaveDetails {
  final String creatorId;
  final String status;
  final String? actionById;
  final String? cancellationReason;
  final String endDate;
  final String reason;
  final String? actionBy;
  final int leaveCnt;
  final String modifiedTime;
  final String username;
  final String userId;
  final String leaveType;
  final String createdTime;
  final String startDate;
  final String rowId;

  LeaveDetails({
    required this.creatorId,
    required this.status,
    this.actionById,
    this.cancellationReason,
    required this.endDate,
    required this.reason,
    this.actionBy,
    required this.leaveCnt,
    required this.modifiedTime,
    required this.username,
    required this.userId,
    required this.leaveType,
    required this.createdTime,
    required this.startDate,
    required this.rowId,
  });

  // Helper method to parse string to int
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to parse nullable string
  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  factory LeaveDetails.fromJson(Map<String, dynamic> json) => LeaveDetails(
        creatorId: json['CREATORID']?.toString() ?? '',
        status: json['Status']?.toString() ?? '',
        actionById: _parseNullableString(json['ActionByID']),
        cancellationReason: _parseNullableString(json['Cancellation_Reason']),
        endDate: json['End_Date']?.toString() ?? '',
        reason: json['Reason']?.toString() ?? '',
        actionBy: _parseNullableString(json['ActionBy']),
        leaveCnt: _parseInt(json['LeaveCnt']),
        modifiedTime: json['MODIFIEDTIME']?.toString() ?? '',
        username: json['Username']?.toString() ?? '',
        userId: json['UserID']?.toString() ?? '',
        leaveType: json['Leave_Type']?.toString() ?? '',
        createdTime: json['CREATEDTIME']?.toString() ?? '',
        startDate: json['Start_Date']?.toString() ?? '',
        rowId: json['ROWID']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'CREATORID': creatorId,
        'Status': status,
        'ActionByID': actionById,
        'Cancellation_Reason': cancellationReason,
        'End_Date': endDate,
        'Reason': reason,
        'ActionBy': actionBy,
        'LeaveCnt': leaveCnt.toString(),
        'MODIFIEDTIME': modifiedTime,
        'Username': username,
        'UserID': userId,
        'Leave_Type': leaveType,
        'CREATEDTIME': createdTime,
        'Start_Date': startDate,
        'ROWID': rowId,
      };

  // Helper methods for display formatting
  String get formattedLeaveType {
    // Convert "Unpaid_Leave" to "Unpaid Leave"
    return leaveType.replaceAll('_', ' ');
  }

  String get formattedStartDate => startDate;
  String get formattedEndDate => endDate;
  String get formattedStatus => status;
  String get formattedLeaveCnt => leaveCnt.toString();
  String get formattedActionBy => actionBy ?? 'N/A';
  String get formattedReason => reason;
  String get formattedCancellationReason => cancellationReason ?? 'N/A';
}

