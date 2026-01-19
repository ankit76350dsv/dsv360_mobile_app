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
}
