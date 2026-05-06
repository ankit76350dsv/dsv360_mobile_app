class ClientContacts {
  final String creatorId;
  final String firstName;
  final String lastName;
  final String orgName;
  final String orgId;
  final String userId;
  final String email;
  final String phone;
  final String modifiedTime;
  final String createdTime;
  final String rowId;
  final bool status;

  ClientContacts({
    required this.creatorId,
    required this.firstName,
    required this.lastName,
    required this.orgName,
    required this.orgId,
    required this.userId,
    required this.email,
    required this.phone,
    required this.modifiedTime,
    required this.createdTime,
    required this.rowId,
    required this.status,
  });

  /// Factory constructor to parse API JSON
  factory ClientContacts.fromJson(Map<String, dynamic> json) {
    return ClientContacts(
      creatorId: json['CREATORID']?.toString() ?? '',
      firstName: json['First_Name']?.toString().trim() ?? '',
      lastName: json['Last_Name']?.toString().trim() ?? '',
      orgName: json['Org_Name']?.toString().trim() ?? '',
      orgId: json['OrgID']?.toString() ?? '',
      userId: json['UserID']?.toString() ?? '',
      email: json['Email']?.toString() ?? '',
      phone: json['Phone']?.toString() ?? '',
      modifiedTime: json['MODIFIEDTIME']?.toString() ?? '',
      createdTime: json['CREATEDTIME']?.toString() ?? '',
      rowId: json['ROWID']?.toString() ?? '',
      status: json['status'] == true,
    );
  }
}
