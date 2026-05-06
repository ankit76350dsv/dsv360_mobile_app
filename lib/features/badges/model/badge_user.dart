class BadgeUser {
  final String fullName;
  final String userId;
  final String profileLink;

  const BadgeUser({
    required this.fullName,
    required this.userId,
    required this.profileLink,
  });

  factory BadgeUser.fromJson(Map<String, dynamic> json) {
    final firstName = (json['first_name'] ?? '').toString();
    final lastName = (json['last_name'] ?? '').toString();

    return BadgeUser(
      fullName: '$firstName $lastName'.trim(),
      userId: (json['user_id'] ?? '').toString(),
      profileLink: (json['profile_pic'] ?? '').toString(),
    );
  }
}
