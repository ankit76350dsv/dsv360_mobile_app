class TaskModel {
  final String id;
  final String taskName;
  final String status;
  final String projectId;
  final DateTime startDate;
  final DateTime endDate;
  final String? assignedTo;
  final String? description;
  final String? owner;
  final int? progress;
  final List<String> attachments;
  final int subTasksCount;
  final int timeEntriesCount;

  TaskModel({
    required this.id,
    required this.taskName,
    required this.status,
    required this.projectId,
    required this.startDate,
    required this.endDate,
    this.assignedTo,
    this.description,
    this.owner,
    this.progress,
    this.attachments = const [],
    this.subTasksCount = 0,
    this.timeEntriesCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskName': taskName,
      'status': status,
      'projectId': projectId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'assignedTo': assignedTo,
      'description': description,
      'owner': owner,
      'progress': progress,
      'attachments': attachments,
      'subTasksCount': subTasksCount,
      'timeEntriesCount': timeEntriesCount,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      taskName: json['taskName'],
      status: json['status'],
      projectId: json['projectId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      assignedTo: json['assignedTo'],
      description: json['description'],
      owner: json['owner'],
      progress: json['progress'],
      attachments: List<String>.from(json['attachments'] ?? []),
      subTasksCount: json['subTasksCount'] ?? 0,
      timeEntriesCount: json['timeEntriesCount'] ?? 0,
    );
  }
}
