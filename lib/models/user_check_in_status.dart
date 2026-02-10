class UserCheckInStatus {
  final bool isCheckIn;
  final DateTime? checkInTime;
  final String? rowId;

  UserCheckInStatus({required this.isCheckIn, this.checkInTime, this.rowId});

  factory UserCheckInStatus.fromJson(Map<String, dynamic> json) {
    return UserCheckInStatus(
      isCheckIn: json['isCheckIn'] ?? false,
      checkInTime: json['Check_In'] != null
          ? DateTime.tryParse(json['Check_In'])
          : null,
      rowId: json['ROWID']?.toString(),
    );
  }
}
