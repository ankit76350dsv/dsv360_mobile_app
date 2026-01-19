class DSVBadge {
  final String badgeLevel;
  final String badgeName;
  final String badgeLogo;
  final String badgeId;
  final String rowId;

  DSVBadge({
    required this.badgeLevel,
    required this.badgeName,
    required this.badgeLogo,
    required this.badgeId,
    required this.rowId,
  });

  /// Parse from API JSON
  factory DSVBadge.fromJson(Map<String, dynamic> json) {
    return DSVBadge(
      badgeLevel: json['Badge_Level']?.toString() ?? '',
      badgeName: json['Badge_Name']?.toString() ?? '',
      badgeLogo: json['Badge_Logo']?.toString() ?? '',
      badgeId: json['Badge_ID']?.toString() ?? '',
      rowId: json['ROWID']?.toString() ?? '',
    );
  }

  /// Convert back to JSON (optional)
  Map<String, dynamic> toJson() => {
        'Badge_Level': badgeLevel,
        'Badge_Name': badgeName,
        'Badge_Logo': badgeLogo,
        'Badge_ID': badgeId,
        'ROWID': rowId,
      };

  // ------------------
  // Helper getters (UI friendly)
  // ------------------

  bool get hasLogo => badgeLogo.isNotEmpty;

  String get displayName => badgeName;

  String get displayLevel => badgeLevel;
}
