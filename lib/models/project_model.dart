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
  final int issuesCount;

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
    this.issuesCount = 0,
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
      'issuesCount': issuesCount,
    };
  }

  // Create from JSON
  // Create from JSON
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['ROWID']?.toString() ?? json['id']?.toString() ?? '',
      projectName: json['Project_Name']?.toString() ?? json['projectName']?.toString() ?? 'Unknown Project',
      status: json['Status']?.toString() ?? json['status']?.toString() ?? 'Unknown',
      client: json['Client_Name']?.toString() ?? json['client']?.toString() ?? 'Unknown Client',
      startDate: _parseDate(json['Start_Date'] ?? json['startDate']),
      endDate: _parseDate(json['End_Date'] ?? json['endDate']),
      assignedTo: json['Assigned_To']?.toString() ?? json['assignedTo']?.toString(),
      description: json['Description']?.toString() ?? json['description']?.toString(),
      owner: json['Owner']?.toString() ?? json['owner']?.toString(),
      progress: json['progress'] ?? 0, // API doesn't seem to return progress, defaulting to 0
      attachments: _parseAttachments(json['Files'] ?? json['attachments']),
      tasksCount: json['tasksCount'] ?? 0,
      timeEntriesCount: json['timeEntriesCount'] ?? 0,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    try {
      return DateTime.parse(date.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  static List<String> _parseAttachments(dynamic files) {
    if (files == null) return [];
    if (files is List) return List<String>.from(files);
    if (files is String && files.isNotEmpty) {
      // Assuming comma separated if string, or just a single file URL? 
      // The sample showed "Files": "", so safe to default to empty list if empty string.
      // If actual URLs come as string, we might need logic here. 
      // For now treating non-empty string as single item list if it looks like a url/path.
      return [files];
    }
    return [];
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
    int? issuesCount,
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
      timeEntriesCount: timeEntriesCount ?? this.timeEntriesCount,      issuesCount: issuesCount ?? this.issuesCount,    );
  }
}
