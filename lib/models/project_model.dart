class ProjectModel {
  final String id;
  final String projectName;
  final String status;
  final String client;
  final DateTime startDate;
  final DateTime endDate;
  final String? assignedTo;
  final String? description;
  final String? owner;
  final int? progress;
  final List<String> attachments;
  final int tasksCount;
  final int timeEntriesCount;

  ProjectModel({
    required this.id,
    required this.projectName,
    required this.status,
    required this.client,
    required this.startDate,
    required this.endDate,
    this.assignedTo,
    this.description,
    this.owner,
    this.progress,
    this.attachments = const [],
    this.tasksCount = 0,
    this.timeEntriesCount = 0,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectName': projectName,
      'status': status,
      'client': client,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'assignedTo': assignedTo,
      'description': description,
      'owner': owner,
      'progress': progress,
      'attachments': attachments,
      'tasksCount': tasksCount,
      'timeEntriesCount': timeEntriesCount,
    };
  }

  // Create from JSON
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      projectName: json['projectName'],
      status: json['status'],
      client: json['client'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      assignedTo: json['assignedTo'],
      description: json['description'],
      owner: json['owner'],
      progress: json['progress'] ?? 0,
      attachments: List<String>.from(json['attachments'] ?? []),
      tasksCount: json['tasksCount'] ?? 0,
      timeEntriesCount: json['timeEntriesCount'] ?? 0,
    );
  }

  // Copy with method for updates
  ProjectModel copyWith({
    String? id,
    String? projectName,
    String? status,
    String? client,
    DateTime? startDate,
    DateTime? endDate,
    String? assignedTo,
    String? description,
    String? owner,
    int? progress,
    List<String>? attachments,
    int? tasksCount,
    int? timeEntriesCount,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      status: status ?? this.status,
      client: client ?? this.client,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      assignedTo: assignedTo ?? this.assignedTo,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      progress: progress ?? this.progress,
      attachments: attachments ?? this.attachments,
      tasksCount: tasksCount ?? this.tasksCount,
      timeEntriesCount: timeEntriesCount ?? this.timeEntriesCount,
    );
  }
}
