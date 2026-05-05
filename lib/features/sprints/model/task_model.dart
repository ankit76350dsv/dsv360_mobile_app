class TaskModel {
  final String id;
  final String title;
  final String description;
  final String storyId;
  final String status;
  final String dueDate;
  final String startDate;
  final int estimatedHours;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.storyId,
    required this.status,
    required this.dueDate,
    required this.startDate,
    required this.estimatedHours,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final storyIdValue =
        json['StoryID'] ?? json['Story_ID'] ?? json['StoryId'];
    final storyId = storyIdValue == null
        ? ''
        : storyIdValue.toString().trim().toLowerCase() == 'null'
            ? ''
            : storyIdValue.toString();
    return TaskModel(
      id: json['ROWID'] ?? '',
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      storyId: storyId,
      status: json['Status'] ?? '',
      dueDate: json['DueDate'] ?? '',
      startDate: json['CREATEDTIME']?.toString() ?? '',
      estimatedHours: int.tryParse(json['EstimatedHours'] ?? '0') ?? 0,
    );
  }
}