class Team {
  final String rowId;
  final String teamName;
  final String teamReportingManagerId;
  final String teamReportingManager;
  final String teamReportingManagerProfile;
  final String orgId;
  final String creatorId;
  final String createdTime;
  final String modifiedTime;

  Team({
    required this.rowId,
    required this.teamName,
    required this.teamReportingManagerId,
    required this.teamReportingManager,
    required this.teamReportingManagerProfile,
    required this.orgId,
    required this.creatorId,
    required this.createdTime,
    required this.modifiedTime,
  });

  /// Factory constructor to parse API JSON response
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      rowId: json['ROWID']?.toString() ?? '',
      teamName: json['Team_Name']?.toString() ?? '',
      teamReportingManagerId: json['Team_Reporting_Manager_ID']?.toString() ?? '',
      teamReportingManager: json['Team_Reporting_Manager']?.toString() ?? '',
      teamReportingManagerProfile:
          json['Team_Reporting_Manager_Profile']?.toString() ?? '',
      orgId: json['Org_Id']?.toString() ?? '',
      creatorId: json['CREATORID']?.toString() ?? '',
      createdTime: json['CREATEDTIME']?.toString() ?? '',
      modifiedTime: json['MODIFIEDTIME']?.toString() ?? '',
    );
  }

  /// Convert Team to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'ROWID': rowId,
      'Team_Name': teamName,
      'Team_Reporting_Manager_ID': teamReportingManagerId,
      'Team_Reporting_Manager': teamReportingManager,
      'Team_Reporting_Manager_Profile': teamReportingManagerProfile,
      'Org_Id': orgId,
      'CREATORID': creatorId,
      'CREATEDTIME': createdTime,
      'MODIFIEDTIME': modifiedTime,
    };
  }

  /// Create payload for team creation API request
  static Map<String, dynamic> createPayload({
    required String teamName,
    required String teamReportingManagerId,
    required String teamReportingManager,
    required String teamReportingManagerProfile,
    required String orgId,
  }) {
    return {
      'Team_Name': teamName,
      'Team_Reporting_Manager_ID': teamReportingManagerId,
      'Team_Reporting_Manager': teamReportingManager,
      'Team_Reporting_Manager_Profile': teamReportingManagerProfile,
      'Org_Id': orgId,
    };
  }
}
