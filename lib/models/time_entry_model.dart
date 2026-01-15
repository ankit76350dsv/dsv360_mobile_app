import 'package:intl/intl.dart';

class TimeEntry {
  final String id;
  final String user;
  final DateTime date;
  final String startTime; // hh:mm format
  final String endTime;   // hh:mm format
  final String type;      // Billable, Non-Billable
  final String note;
  final DateTime createdAt;

  TimeEntry({
    required this.id,
    required this.user,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Helper method to calculate duration in hours
  double getDurationInHours() {
    try {
      final format = DateFormat('HH:mm');
      final start = format.parse(startTime);
      final end = format.parse(endTime);
      
      Duration duration = end.difference(start);
      if (duration.isNegative) {
        // If end time is before start time, assume next day
        duration = Duration(hours: 24) + duration;
      }
      return duration.inMinutes / 60.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'date': DateFormat('dd-MM-yyyy').format(date),
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      user: json['user'],
      date: DateFormat('dd-MM-yyyy').parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      type: json['type'],
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
