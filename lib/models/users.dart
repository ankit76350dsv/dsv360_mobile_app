enum WorkStatus { active, inactive }

enum VerificationStatus { pending, verified }

class UsersModel {
  final String firstName;
  final String lastName;
  final String userId;
  final String emailAddress;
  final String role;
  final String roleId;
  final String profilePic;
  final WorkStatus workStatus;
  final VerificationStatus verificationStatus;

  // New fields
  final String? reporterId;
  final String? reporterName;
  final String? reporterProfile;
  final String? empId;
  final String? teamId;
  final String? teamName;
  final String? phone;
  final String? shiftStartTime;
  final String? shiftEndTime;
  final String? location;

  UsersModel({
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.emailAddress,
    required this.role,
    required this.roleId,
    required this.profilePic,
    required this.workStatus,
    required this.verificationStatus,
    this.reporterId,
    this.reporterName,
    this.reporterProfile,
    this.empId,
    this.teamId,
    this.teamName,
    this.phone,
    this.shiftStartTime,
    this.shiftEndTime,
    this.location,
  });

  /// API: status -> WorkStatus
  static WorkStatus _workStatusFromApi(dynamic value) {
    switch (value) {
      case 'ACTIVE':
        return WorkStatus.active;
      case 'DISABLED':
        return WorkStatus.inactive;
      default:
        return WorkStatus.inactive;
    }
  }

  /// API: is_confirmed -> VerificationStatus
  static VerificationStatus _verificationStatusFromApi(dynamic value) {
    return value == true
        ? VerificationStatus.verified
        : VerificationStatus.pending;
  }

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      emailAddress: json['email_id'] ?? '',
      role: json['role_details']?['role_name'] ?? '',
      roleId: json['role_details']?['role_id']?.toString() ?? '',
      reporterId: json['reporter_id']?.toString(),
      reporterName: json['reporter_name'],
      reporterProfile: json['reporter_profile'],
      profilePic: json['profile_pic'] ?? '',
      workStatus: _workStatusFromApi(json['status']),
      verificationStatus: _verificationStatusFromApi(json['is_confirmed']),
      empId: json['emp_id']?.toString(),
      teamId: json['team_id']?.toString(),
      teamName: json['team_name'],
      phone: json['phone']?.toString(),
      shiftStartTime: json['shift_start_time'],
      shiftEndTime: json['shift_end_time'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'user_id': userId,
    'email_id': emailAddress,
    'role': role,
    'roleId': roleId,
    'profile_pic': profilePic,
    'status': workStatus == WorkStatus.active ? 'ENABLED' : 'DISABLED',
    'is_confirmed': verificationStatus == VerificationStatus.verified,
    'reporterId': reporterId,
    'reporterName': reporterName,
    'reporterProfile': reporterProfile,
    'emp_id': empId,
    'team_id': teamId,
    'team_name': teamName,
    'phone': phone,
    'shift_start_time': shiftStartTime,
    'shift_end_time': shiftEndTime,
    'location': location,
  };

  /// Convenience getter for UI
  String get fullName => '$firstName $lastName'.trim();
}
