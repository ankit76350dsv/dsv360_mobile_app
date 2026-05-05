class Task {
  final String taskName;
  final String taskId;
  final String description;
  final String status;
  final String projectId;
  final String projectName;
  final String assignedTo;
  final String assignedToId;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> attachments;

  // Temporary field for passing attachments through dialog
  // Not part of API response, only used internally
  final List<dynamic>? _attachmentsForCreation;

  Task({
    required this.taskName,
    required this.taskId,
    required this.description,
    required this.status,
    required this.projectId,
    required this.projectName,
    required this.assignedTo,
    required this.assignedToId,
    this.startDate,
    this.endDate,
    this.attachments = const [],
    List<dynamic>? attachmentsForCreation,
  }) : _attachmentsForCreation = attachmentsForCreation;

  // Getter to access attachments
  List<dynamic>? get attachmentsForCreation => _attachmentsForCreation;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskName: json['Task_Name']?.toString() ?? "",
      taskId: json['ROWID']?.toString() ?? "",
      description: json['Description']?.toString() ?? "",
      status: json['Status']?.toString() ?? "",
      projectId: json['ProjectID']?.toString() ?? "",
      projectName: json['Project_Name']?.toString() ?? "",
      assignedTo: json['Assign_To']?.toString() ?? "",
      assignedToId: json['Assign_To_ID']?.toString() ?? "",
      startDate: _parseDate(json['Start_Date']),
      endDate: _parseDate(json['End_Date']),
      attachments: _parseAttachments(json['Files'] ?? json['attachments']),
      attachmentsForCreation: null,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }

  static List<String> _parseAttachments(dynamic files) {
    if (files == null) return [];
    if (files is List) return List<String>.from(files);
    if (files is String && files.isNotEmpty) {
      return files.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }
}