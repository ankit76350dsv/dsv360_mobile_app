class FeedbackModel {
  final String id;
  final String name;
  final String email;
  final String message;
  final List<String> images;
  final DateTime date;
  final String status;

  FeedbackModel({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.images,
    required this.date,
    required this.status,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'message': message,
      'images': images,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
