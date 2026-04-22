class CreateReleaseModel {
  final String title;
  final String projectId;
  final String dueDate;
  final String description;

  CreateReleaseModel({
    required this.title,
    required this.projectId,
    required this.dueDate,
    required this.description,
  });

  factory CreateReleaseModel.fromJson(Map<String, dynamic> json) {
    return CreateReleaseModel(
      title: json['Title'] ?? '',
      projectId: json['ProjectID'] ?? '',
      dueDate: json['DueDate'] ?? '',
      description: json['Description'] ?? '',
    );
  }
}
