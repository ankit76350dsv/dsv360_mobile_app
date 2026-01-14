enum UserRole { admin, user }

class CurrentUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  CurrentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;

  CurrentUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
  }) {
    return CurrentUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
