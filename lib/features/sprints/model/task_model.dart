class TaskModel {
  final String id;
  final String sprintTaskId;
  final String title;
  final String description;
  final String storyId;
  final String status;
  final String dueDate;
  final String startDate;
  final int estimatedHours;

  TaskModel({
    required this.id,
    required this.sprintTaskId,
    required this.title,
    required this.description,
    required this.storyId,
    required this.status,
    required this.dueDate,
    required this.startDate,
    required this.estimatedHours,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final storyIdValue = json['StoryID'] ?? json['Story_ID'] ?? json['StoryId'];
    final storyId = storyIdValue == null
        ? ''
        : storyIdValue.toString().trim().toLowerCase() == 'null'
        ? ''
        : storyIdValue.toString();

    final idValue =
        json['ROWID'] ??
        json['TaskID'] ??
        json['Task_ID'] ??
        json['TaskId'] ??
        json['id'];
    final id = idValue == null
        ? ''
        : idValue.toString().trim().toLowerCase() == 'null'
        ? ''
        : idValue.toString();

    final sprintTaskIdValue =
        json['Sprint_Task_ID'] ??
        json['SprintTaskID'] ??
        json['SprintTaskId'];
    final sprintTaskId = sprintTaskIdValue == null
        ? ''
        : sprintTaskIdValue.toString().trim().toLowerCase() == 'null'
        ? ''
        : sprintTaskIdValue.toString();

    return TaskModel(
      id: id,
      sprintTaskId: sprintTaskId.isNotEmpty ? sprintTaskId : id,
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
