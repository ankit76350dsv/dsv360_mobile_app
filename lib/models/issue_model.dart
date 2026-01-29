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

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['ROWID']?.toString() ?? '',
      issueName: json['Issue_name'] ?? '',
      status: json['Status'] ?? 'Open',
      priority: json['Severity'] ?? 'Medium',
      description: json['Description'],
      assignedTo: json['Assignee_Name'],
      owner: json['Reporter_Name'],
      createdDate: _parseDate(json['CREATEDTIME']),
      dueDate: _parseDate(json['Due_Date']),
      projectId: json['Project_ID']?.toString(),
      projectName: json['Project_Name'],
      attachments: _parseAttachments(json['Files']),
      commentsCount: 0,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static List<String> _parseAttachments(dynamic attachments) {
    if (attachments == null) return [];
    if (attachments is List) {
      return attachments.map((e) => e.toString()).toList();
    }
    if (attachments is String && attachments.isNotEmpty) {
      return [attachments];
    }
    return [];
  }
}
