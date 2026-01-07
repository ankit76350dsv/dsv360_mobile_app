enum WorkStatus { active, inactive }
enum VerificationStatus { pending, verified }

class UsersModel {
  final String firstName;
  final String lastName;
  final String userId;
  final String emailAddress;
  final String role;
  final String profilePic;
  final WorkStatus workStatus;
  final VerificationStatus verificationStatus;

  UsersModel({
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.emailAddress,
    required this.role,
    required this.profilePic,
    required this.workStatus,
    required this.verificationStatus,
  });

  /// API: status -> WorkStatus
  static WorkStatus _workStatusFromApi(dynamic value) {
    switch (value) {
      case 'ENABLED':
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
      profilePic: json['profile_pic'] ?? '',
      workStatus: _workStatusFromApi(json['status']),
      verificationStatus:
          _verificationStatusFromApi(json['is_confirmed']),
    );
  }

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'user_id': userId,
        'email_id': emailAddress,
        'role': role,
        'profile_pic': profilePic,
        'status': workStatus == WorkStatus.active
            ? 'ENABLED'
            : 'DISABLED',
        'is_confirmed':
            verificationStatus == VerificationStatus.verified,
      };

  /// Convenience getter for UI
  String get fullName => '$firstName $lastName'.trim();
}
