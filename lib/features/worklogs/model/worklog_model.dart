class WorklogEntry {
  final String id;
  final String project;
  final String task;
  final String description;
  final String start;
  final String end;
  final String hours;
  final String status;
  final String sourceType;

  const WorklogEntry({
    required this.id,
    required this.project,
    required this.task,
    required this.description,
    required this.start,
    required this.end,
    required this.hours,
    required this.status,
    required this.sourceType,
  });

  factory WorklogEntry.fromJson(Map<String, dynamic> json) {
    return WorklogEntry(
      id: json['id']?.toString() ?? '',
      project: json['project']?.toString() ?? '',
      task: json['task']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      hours: json['hours']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      sourceType: json['sourceType']?.toString() ?? '',
    );
  }
}

class WorklogDaySummary {
  final String date;
  final String totalHours;
  final List<WorklogEntry> entries;

  const WorklogDaySummary({
    required this.date,
    required this.totalHours,
    required this.entries,
  });

  factory WorklogDaySummary.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    final entries = (rawEntries is List)
        ? rawEntries
            .whereType<Map>()
            .map((e) => WorklogEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <WorklogEntry>[];

    return WorklogDaySummary(
      date: json['date']?.toString() ?? '',
      totalHours: json['totalHours']?.toString() ?? '00:00',
      entries: entries,
    );
  }
}
