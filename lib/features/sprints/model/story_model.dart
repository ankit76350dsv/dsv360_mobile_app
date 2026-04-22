class StoryModel {
  final String id;
  final String title;
  final String description;
  final String epicId;
  final String sprintId;
  final String status;
  final int points;
  final String priority;

  StoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.epicId,
    required this.sprintId,
    required this.status,
    required this.points,
    required this.priority,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['ROWID'] ?? '',
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      epicId: json['EpicID'] ?? '',
      sprintId: json['SprintID'] ?? '',
      status: json['Status'] ?? '',
      points: int.tryParse(json['Points'] ?? '0') ?? 0,
      priority: json['Priority'] ?? '',
    );
  }
}