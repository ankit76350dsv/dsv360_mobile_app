class Employee {
  final String userId;
  final String firstName;
  final String lastName;
  final String emailId;
  final String status;
  final bool isConfirmed;
  final String roleId;
  final String roleName;

  Employee({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.emailId,
    required this.status,
    required this.isConfirmed,
    required this.roleId,
    required this.roleName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      userId: json['user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'INACTIVE',
      isConfirmed: json['is_confirmed'] ?? false,
      roleId: (json['role_details'] as Map<String, dynamic>?)?['role_id']?.toString() ?? '',
      roleName: (json['role_details'] as Map<String, dynamic>?)?['role_name']?.toString() ?? '',
    );
  }

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email_id': emailId,
      'status': status,
      'is_confirmed': isConfirmed,
      'role_details': {
        'role_id': roleId,
        'role_name': roleName,
      },
    };
  }
}
