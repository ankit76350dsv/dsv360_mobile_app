class SprintStory {
  final String id;
  final String title;
  final int completedPoints;
  final int totalPoints;
  final List<String> memberAvatars;
  final String storyLabel;
  final int storyPoints;
  String columnId;
  String status;

  SprintStory({
    required this.id,
    required this.title,
    required this.completedPoints,
    required this.totalPoints,
    required this.memberAvatars,
    required this.storyLabel,
    required this.storyPoints,
    required this.columnId,
    required this.status,
  });
}
