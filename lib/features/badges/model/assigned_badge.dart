class AssignedBadge {
  final String badgeName;
  final String badgeLevel;
  final String badgeLogo;
  final String badgeId;
  final String rowId;

  const AssignedBadge({
    required this.badgeName,
    required this.badgeLevel,
    required this.badgeLogo,
    required this.badgeId,
    required this.rowId,
  });

  factory AssignedBadge.fromJson(Map<String, dynamic> json) {
    return AssignedBadge(
      badgeName: (json['Badge_Name'] ?? '').toString(),
      badgeLevel: (json['Badge_Level'] ?? '').toString(),
      badgeLogo: (json['Badge_Logo'] ?? '').toString(),
      badgeId: (json['Badge_ID'] ?? '').toString(),
      rowId: (json['ROWID'] ?? '').toString(),
    );
  }
}
