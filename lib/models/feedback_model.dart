class FeedbackModel {
  final String id;
  final String name;
  final String email;
  final String message;
  final List<String> images;
  final DateTime date;
  final String status;
  final String? responseByName;
  final String? responseById;
  final String? resolvedMessage;

  FeedbackModel({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.images,
    required this.date,
    required this.status,
    this.responseByName,
    this.responseById,
    this.resolvedMessage,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['ROWID']?.toString() ?? json['id']?.toString() ?? '',
      name: json['Name'] ?? json['name'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      message: json['Message'] ?? json['message'] ?? '',
      images: _parseImages(json['Images'] ?? json['images']),
      date: _parseDateTime(json['CREATEDTIME'] ?? json['date']),
      status: _parseStatus(json['Status'] ?? json['status']),
      responseByName: json['ResponseByName'],
      responseById: json['ResponseByID'],
      resolvedMessage: json['Resolved_Message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ROWID': id,
      'Name': name,
      'Email': email,
      'Message': message,
      'Images': images.join(','),
      'CREATEDTIME': date.toIso8601String(),
      'Status': status == 'Resolved',
      'ResponseByName': responseByName,
      'ResponseByID': responseById,
      'Resolved_Message': resolvedMessage,
    };
  }

  static List<String> _parseImages(dynamic images) {
    if (images == null) return [];
    if (images is String && images.isNotEmpty) {
      return images.split(',').map((e) => e.trim()).toList();
    }
    if (images is List) {
      return List<String>.from(images.map((e) => e.toString()));
    }
    return [];
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      try {
        // Try parsing standard format
        return DateTime.parse(date);
      } catch (e) {
        try {
          // Handle format "2025-06-06 12:27:57:048"
          // Replace space with T
          String formatted = date.trim().replaceAll(' ', 'T');
          // Replace last colon with dot if it looks like milliseconds
          // This is a bit risky if timezone offset is involved, but the sample doesn't have offset
          // Regex to replace :SSS at the end with .SSS
          // Or just string manipulation
          if (formatted.contains(':') && formatted.length > 20) {
            int lastColon = formatted.lastIndexOf(':');
            if (lastColon > formatted.lastIndexOf('T')) {
              formatted =
                  formatted.substring(0, lastColon) +
                  '.' +
                  formatted.substring(lastColon + 1);
            }
          }
          return DateTime.parse(formatted);
        } catch (_) {
          return DateTime.now();
        }
      }
    }
    return DateTime.now();
  }

  static String _parseStatus(dynamic status) {
    if (status is bool) {
      return status ? 'Resolved' : 'Pending';
    }
    if (status is String) {
      return status;
    }
    return 'Pending';
  }
}
