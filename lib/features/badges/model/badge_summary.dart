class BadgeSummary {
  final String badgeId;
  final String badgeName;
  final String badgeLevel;
  final String badgeLogo;
  final String rowId;
  final String username;

  const BadgeSummary({
    required this.badgeId,
    required this.badgeName,
    required this.badgeLevel,
    required this.badgeLogo,
    required this.rowId,
    required this.username,
  });

  factory BadgeSummary.fromJson(Map<String, dynamic> json) {
    String asString(dynamic value) => value?.toString() ?? '';

    return BadgeSummary(
      badgeId: asString(json['Badge_ID']),
      badgeName: asString(json['Badge_Name']),
      badgeLevel: asString(json['Badge_Level']),
      badgeLogo: asString(json['Badge_Logo']),
      rowId: asString(json['ROWID'] ?? json['rowId']),
      username: asString(json['Username']),
    );
  }
}
