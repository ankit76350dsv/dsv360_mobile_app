class Organization {
  final String creatorId;
  final String orgName;
  final String status;
  final String modifiedTime;
  final String email;
  final String orgImg;
  final String website;
  final String createdTime;
  final String orgType;
  final String rowId;

  Organization({
    required this.creatorId,
    required this.orgName,
    required this.status,
    required this.modifiedTime,
    required this.email,
    required this.orgImg,
    required this.website,
    required this.createdTime,
    required this.orgType,
    required this.rowId,
  });

  /// Factory constructor to parse API JSON
  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      creatorId: json['CREATORID']?.toString() ?? '',
      orgName: json['Org_Name']?.toString().trim() ?? '',
      status: json['Status']?.toString() ?? '',
      modifiedTime: json['MODIFIEDTIME']?.toString() ?? '',
      email: json['Email']?.toString() ?? '',
      orgImg: json['Org_Img']?.toString() ?? '',
      website: json['Website']?.toString() ?? '',
      createdTime: json['CREATEDTIME']?.toString() ?? '',
      orgType: json['Org_Type']?.toString() ?? '',
      rowId: json['ROWID']?.toString() ?? '',
    );
  }

  /// Convert Organization to JSON
  Map<String, dynamic> toJson() {
    return {
      'CREATORID': creatorId,
      'Org_Name': orgName,
      'Status': status,
      'MODIFIEDTIME': modifiedTime,
      'Email': email,
      'Org_Img': orgImg,
      'Website': website,
      'CREATEDTIME': createdTime,
      'Org_Type': orgType,
      'ROWID': rowId,
    };
  }

  /// Check if organization is active
  bool get isActive => status.toLowerCase() == 'active';
}
