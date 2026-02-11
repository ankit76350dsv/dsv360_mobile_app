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

  // Create from JSON - Maps backend response fields
  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    // Parse start time - handles both AM/PM and 24-hour formats
    String parseTime(String timeStr) {
      try {
        // Check if time is in AM/PM format (contains AM/PM)
        if (timeStr.contains('AM') || timeStr.contains('PM')) {
          final format = DateFormat('hh:mm a'); // "6:44 PM" format
          final time = format.parse(timeStr);
          return DateFormat('HH:mm').format(time); // Convert to 24-hour format
        } else {
          // Already in 24-hour format like "18:26"
          // Validate it's proper HH:mm format
          if (timeStr.contains(':')) {
            final parts = timeStr.split(':');
            if (parts.length >= 2) {
              return '${parts[0].padLeft(2, '0')}:${parts[1].substring(0, 2).padLeft(2, '0')}';
            }
          }
          return timeStr;
        }
      } catch (e) {
        // If parsing fails, return as-is
        return timeStr;
      }
    }

    // Parse CREATEDTIME format: "2026-02-05 17:28:58:810" -> convert to ISO format
    DateTime parseCreatedTime(String timeStr) {
      try {
        // Replace the last colon with a dot for milliseconds: "2026-02-05 17:28:58:810" -> "2026-02-05T17:28:58.810"
        final normalized = timeStr.replaceAll(' ', 'T').replaceRange(timeStr.lastIndexOf(':'), timeStr.lastIndexOf(':') + 1, '.');
        return DateTime.parse(normalized);
      } catch (e) {
        // Fallback: try to parse just the date part
        try {
          return DateFormat('yyyy-MM-dd').parse(timeStr.split(' ')[0]);
        } catch (e2) {
          return DateTime.now();
        }
      }
    }

    return TimeEntry(
      id: json['ROWID']?.toString() ?? json['id'] ?? '',
      user: json['Username']?.toString() ?? json['user'] ?? '',
      date: json['Entry_Date'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['Entry_Date'].toString())
          : DateTime.now(),
      startTime: parseTime(json['Start_time']?.toString() ?? ''),
      endTime: parseTime(json['End_time']?.toString() ?? ''),
      type: json['Type']?.toString() ?? json['type'] ?? 'Non-Billable',
      note: json['Note']?.toString() ?? json['note'] ?? '',
      createdAt: json['CREATEDTIME'] != null
          ? parseCreatedTime(json['CREATEDTIME'].toString())
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now()),
    );
  }
}
