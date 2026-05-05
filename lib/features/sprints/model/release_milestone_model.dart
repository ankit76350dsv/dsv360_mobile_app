class ReleaseMilestoneModel {
  final String id;
  final String title;
  final String description;
  final String dueDate;

  ReleaseMilestoneModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
  });

  factory ReleaseMilestoneModel.fromJson(Map<String, dynamic> json) {
    return ReleaseMilestoneModel(
      id: json['ROWID'] ?? '',
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      dueDate: json['DueDate'] ?? '',
    );
  }
}