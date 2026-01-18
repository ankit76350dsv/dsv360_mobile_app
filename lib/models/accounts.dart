class Account {
  final String orgName;
  final String status;
  final String email;
  final String? orgImg;
  final String website;
  final String orgType;
  final String rowId;

  Account({
    required this.orgName,
    required this.status,
    required this.email,
    this.orgImg,
    required this.website,
    required this.orgType,
    required this.rowId,
  });

  /// Factory constructor to parse API JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      orgName: json['Org_Name']?.toString() ?? '',
      status: json['Status']?.toString() ?? '',
      email: json['Email']?.toString() ?? '',
      orgImg: (json['Org_Img']?.toString().isEmpty ?? true)
          ? null
          : json['Org_Img'].toString(),
      website: json['Website']?.toString() ?? '',
      orgType: json['Org_Type']?.toString() ?? '',
      rowId: json['ROWID']?.toString() ?? '',
    );
  }

  /// Convert model back to JSON (optional)
  Map<String, dynamic> toJson() => {
        'Org_Name': orgName,
        'Status': status,
        'Email': email,
        'Org_Img': orgImg ?? '',
        'Website': website,
        'Org_Type': orgType,
        'ROWID': rowId,
      };

  // ------------------
  // Helper getters (UI friendly)
  // ------------------

  bool get hasLogo => orgImg != null && orgImg!.isNotEmpty;

  String get formattedOrgType => orgType;

  String get formattedStatus => status;

  String get displayEmail => email;

  String get displayWebsite => website.isEmpty ? 'N/A' : website;
}
