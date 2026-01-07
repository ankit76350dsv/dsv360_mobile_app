class Task {
  final String taskName;
  final String description;
  final String status;
  final String projectName;
  final String assignedTo;
  final DateTime startDate;
  final DateTime endDate;

  Task({
    required this.taskName,
    required this.description,
    required this.status,
    required this.projectName,
    required this.assignedTo,
    required this.startDate,
    required this.endDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskName: json['Task_Name'] ?? '',
      description: json['Description'] ?? '',
      status: json['Status'] ?? '',
      projectName: json['Project_Name'] ?? '',
      assignedTo: json['Assign_To'] ?? '',
      startDate: DateTime.parse(json['Start_Date']),
      endDate: DateTime.parse(json['End_Date']),
    );
  }
}
