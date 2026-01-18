class Task {
  final String taskName;
  final String description;
  final String status;
  final String projectId;
  final String projectName;
  final String assignedTo;
  final String assignedToId;
  final DateTime? startDate;
  final DateTime? endDate;

  Task({
    required this.taskName,
    required this.description,
    required this.status,
    required this.projectId,
    required this.projectName,
    required this.assignedTo,
    required this.assignedToId,
    this.startDate,
    this.endDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskName: json['Task_Name']?.toString() ?? "",
      description: json['Description']?.toString() ?? "",
      status: json['Status']?.toString() ?? "",
      projectId: json['ProjectID']?.toString() ?? "",
      projectName: json['Project_Name']?.toString() ?? "",
      assignedTo: json['Assign_To']?.toString() ?? "",
      assignedToId: json['Assign_To_ID']?.toString() ?? "",
      startDate: _parseDate(json['Start_Date']),
      endDate: _parseDate(json['End_Date']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
}