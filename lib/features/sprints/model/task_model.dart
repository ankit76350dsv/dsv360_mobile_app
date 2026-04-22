class TaskModel {
  final String id;
  final String title;
  final String description;
  final String storyId;
  final String status;
  final String dueDate;
  final int estimatedHours;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.storyId,
    required this.status,
    required this.dueDate,
    required this.estimatedHours,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['ROWID'] ?? '',
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      storyId: json['StoryID'] ?? '',
      status: json['Status'] ?? '',
      dueDate: json['DueDate'] ?? '',
      estimatedHours: int.tryParse(json['EstimatedHours'] ?? '0') ?? 0,
    );
  }
}