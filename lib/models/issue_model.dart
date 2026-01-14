class IssueModel {
  final String id;
  final String issueName;
  final String status;
  final String priority;
  final String? description;
  final String? assignedTo;
  final String? owner;
  final DateTime createdDate;
  final DateTime? dueDate;
  final String? projectId;
  final String? projectName;
  final List<String> attachments;
  final int commentsCount;

  IssueModel({
    required this.id,
    required this.issueName,
    required this.status,
    required this.priority,
    this.description,
    this.assignedTo,
    this.owner,
    required this.createdDate,
    this.dueDate,
    this.projectId,
    this.projectName,
    this.attachments = const [],
    this.commentsCount = 0,
  });
}
