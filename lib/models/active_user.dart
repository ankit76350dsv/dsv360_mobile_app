class ActiveUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  ActiveUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory ActiveUser.fromJson(Map<String, dynamic> json) {
    return ActiveUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}
