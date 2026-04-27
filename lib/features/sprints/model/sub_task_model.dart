class SubTaskModel {
  final String rowId;
  final String title;
  final String description;
  final String status;

  final bool isDeleted;

  final String taskId;
  final String storyId;
  final String projectId;
  final String orgId;
  final String assigneeId;

  final double estimatedHours;

  final DateTime? dueDate;

  final String createdTime;
  final String modifiedTime;

  SubTaskModel({
    required this.rowId,
    required this.title,
    required this.description,
    required this.status,
    required this.isDeleted,
    required this.taskId,
    required this.storyId,
    required this.projectId,
    required this.orgId,
    required this.assigneeId,
    required this.estimatedHours,
    required this.dueDate,
    required this.createdTime,
    required this.modifiedTime,
  });

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      rowId: json['ROWID']?.toString() ?? '',
      title: json['Title']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      status: json['Status']?.toString() ?? '',

      isDeleted: json['IsDeleted'] == '1',

      taskId: json['TaskID']?.toString() ?? '',
      storyId: json['StoryID']?.toString() ?? '',
      projectId: json['ProjectID']?.toString() ?? '',
      orgId: json['OrgID']?.toString() ?? '',
      assigneeId: json['AssigneeID']?.toString() ?? '',

      estimatedHours: double.tryParse(
        json['EstimatedHours']?.toString() ?? '0'
      ) ?? 0,

      dueDate: json['DueDate'] != null
          ? DateTime.tryParse(json['DueDate'])
          : null,

      createdTime: json['CREATEDTIME']?.toString() ?? '',
      modifiedTime: json['MODIFIEDTIME']?.toString() ?? '',
    );
  }
}