class Project {
  final String id;
  final String name;
  final String status;
  final int tasksCount;

  Project({
    required this.id,
    required this.name,
    required this.status,
    this.tasksCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        status: json['status']?.toString() ?? 'unknown',
        tasksCount: (json['tasks_count'] is int) ? json['tasks_count'] as int : int.tryParse(json['tasks_count']?.toString() ?? '') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'tasks_count': tasksCount,
      };
}
