class UserProfileModel {
  final String address;
  final String aboutMe;
  final String resumeId;
  final String teamName;
  final String teamId;
  final String roleId;
  final String orgId;
  final String reporterImage;
  final String skills;
  final String phone;
  final String countryCode;
  final String shiftEndTime;
  final String creatorId;
  final String reporterName;
  final String reporterId;
  final String resumeLink;
  final String coverLink;
  final String shiftStartTime;
  final String modifiedTime;
  final String username;
  final String createdTime;
  final String userId;
  final String profileLink;
  final String empId;
  final String rowId;
  final String location;

  UserProfileModel({
    required this.address,
    required this.aboutMe,
    required this.resumeId,
    required this.teamName,
    required this.teamId,
    required this.roleId,
    required this.orgId,
    required this.reporterImage,
    required this.skills,
    required this.phone,
    required this.countryCode,
    required this.shiftEndTime,
    required this.creatorId,
    required this.reporterName,
    required this.reporterId,
    required this.resumeLink,
    required this.coverLink,
    required this.shiftStartTime,
    required this.modifiedTime,
    required this.username,
    required this.createdTime,
    required this.userId,
    required this.profileLink,
    required this.empId,
    required this.rowId,
    required this.location,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely handle nulls
    String val(dynamic v) => (v ?? '').toString();

    // The API seems to wrap the response in a "data" field, but the example
    // provided shows the fields directly inside the "data" object.
    // Assuming the repository extracts the "data" map before passing it here.
    return UserProfileModel(
      address: val(json['Address']),
      aboutMe: val(json['AboutME']),
      resumeId: val(json['Resume_id']),
      teamName: val(json['TeamName']),
      teamId: val(json['TeamID']),
      roleId: val(json['RoleID']),
      orgId: val(json['OrgID']),
      reporterImage: val(json['ReporterImage']),
      skills: val(json['Skills']),
      phone: val(json['Phone']),
      countryCode: val(json['CountryCode']),
      shiftEndTime: val(json['Shift_End_Time']),
      creatorId: val(json['CREATORID']),
      reporterName: val(json['ReporterName']),
      reporterId: val(json['ReporterID']),
      resumeLink: val(json['Resume_Link']),
      coverLink: val(json['Cover_Link']),
      shiftStartTime: val(json['Shift_Start_Time']),
      modifiedTime: val(json['MODIFIEDTIME']),
      username: val(json['Username']),
      createdTime: val(json['CREATEDTIME']),
      userId: val(json['User_Id']),
      profileLink: val(json['Profile_Link']),
      empId: val(json['EmpID']),
      rowId: val(json['ROWID']),
      location: val(json['Location']),
    );
  }
}
