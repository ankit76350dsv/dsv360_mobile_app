class SprintModel {
  final String rowId;
  final String sprintName;
  final String goal;
  final String projectId;
  final String startDate;
  final String endDate;
  final String status;
  final String createdTime;
  final String modifiedTime;
  final String orgId;
  final String isDeleted;

  SprintModel({
    required this.rowId,
    required this.sprintName,
    required this.goal,
    required this.projectId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdTime,
    required this.modifiedTime,
    required this.orgId,
    required this.isDeleted,
  });

  factory SprintModel.fromJson(Map<String, dynamic> json) {
    return SprintModel(
      rowId: json['ROWID'] ?? '',
      sprintName: json['SprintName'] ?? '',
      goal: json['Goal'] ?? '',
      projectId: json['ProjectID'] ?? '',
      startDate: json['StartDate'] ?? '',
      endDate: json['EndDate'] ?? '',
      status: json['Status'] ?? '',
      createdTime: json['CREATEDTIME'] ?? '',
      modifiedTime: json['MODIFIEDTIME'] ?? '',
      orgId: json['OrgID'] ?? '',
      isDeleted: json['IsDeleted'] ?? '',
    );
  }
}