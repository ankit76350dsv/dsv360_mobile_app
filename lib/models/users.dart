enum WorkStatus { active, resigned, left }

enum VerificationStatus { pending, verified }

class UsersModel {
  final String name;
  final String userId;
  final String emailAddress;
  final String role;
  final WorkStatus workStatus;
  final VerificationStatus verificationStatus;

  UsersModel({
    required this.name,
    required this.userId,
    required this.emailAddress,
    required this.role,
    required this.workStatus,
    required this.verificationStatus,
  });

  // Helper to convert from String to WorkStatus enum
  static WorkStatus _workStatusFromString(dynamic value) {
    switch (value) {
      case 'active':
        return WorkStatus.active;
      case 'resigned':
        return WorkStatus.resigned;
      case 'left':
        return WorkStatus.left;
      default:
        return WorkStatus.active;
    }
  }

  // Helper to convert from String to VerificationStatus enum
  static VerificationStatus _verificationStatusFromString(dynamic value) {
    switch (value) {
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      default:
        return VerificationStatus.pending;
    }
  }

  factory UsersModel.fromJson(Map<String, dynamic> json) => UsersModel(
    name: json['name'] ?? '',
    userId: json['userId'] ?? '',
    emailAddress: json['emailAddress'] ?? '',
    role: json['role'] ?? '',
    workStatus: _workStatusFromString(json['workStatus']),
    verificationStatus: _verificationStatusFromString(
      json['verificationStatus'],
    ),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'userId': userId,
    'emailAddress': emailAddress,
    'role': role,
    'workStatus': workStatus.name, // "active" / "resigned" / "left"
    'verificationStatus': verificationStatus.name, // "pending" / "verified"
  };
}
