class BatchProfile {
  final String zuid;
  final String zaaid;
  final String orgId;
  final String status;
  final bool isConfirmed;
  final String emailId;
  final String firstName;
  final String lastName;
  final String userId;
  final String userType;
  final String profilePic;
  final String? phone;
  final String? teamId;
  final String? teamName;

  const BatchProfile({
    required this.zuid,
    required this.zaaid,
    required this.orgId,
    required this.status,
    required this.isConfirmed,
    required this.emailId,
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.userType,
    required this.profilePic,
    this.phone,
    this.teamId,
    this.teamName,
  });

  factory BatchProfile.fromJson(Map<String, dynamic> json) {
    return BatchProfile(
      zuid: json['zuid']?.toString() ?? '',
      zaaid: json['zaaid']?.toString() ?? '',
      orgId: json['org_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isConfirmed: json['is_confirmed'] == true,
      emailId: json['email_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? '',
      profilePic: json['profile_pic']?.toString() ?? '',
      phone: json['phone'] != null ? json['phone'].toString() : null,
      teamId: json['team_id'] != null ? json['team_id'].toString() : null,
      teamName: json['team_name'] != null ? json['team_name'].toString() : null,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
