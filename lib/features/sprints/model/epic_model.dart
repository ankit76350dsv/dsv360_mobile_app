class EpicModel {
  final String id;
  final String title;
  final String description;
  final String milestoneId;
  final String color;

  EpicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.milestoneId,
    required this.color,
  });

  factory EpicModel.fromJson(Map<String, dynamic> json) {
    return EpicModel(
      id: json['ROWID'] ?? '',
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      milestoneId: json['MilestoneID'] ?? '',
      color: json['Color'] ?? '',
    );
  }
}