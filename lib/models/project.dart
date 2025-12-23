class Project {
  final String id;
  final String name;
  final String status;
  final int tasksCount;
  final DateTime? startDate;

  Project({
    required this.id,
    required this.name,
    required this.status,
    this.tasksCount = 0,
    this.startDate,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        status: json['status']?.toString() ?? 'unknown',
        tasksCount: (json['tasks_count'] is int) ? json['tasks_count'] as int : int.tryParse(json['tasks_count']?.toString() ?? '') ?? 0,
        startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'].toString()) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'tasks_count': tasksCount,
        'start_date': startDate?.toIso8601String(),
      };
}
