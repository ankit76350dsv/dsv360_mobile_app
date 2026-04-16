import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CreateFeedbackRepository {
  final _client = ApiClient.instance;

  Future<void> createFeedback({
    required String name,
    required String email,
    required String message,
    List<XFile> images = const [],
  }) async {
    const path = 'time_entry_management_application_function/feedback';

    final user = AuthManager.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    if (images.length > 3) throw Exception('Maximum 3 images allowed');

    final formData = FormData.fromMap({
      'Name': name.trim(),
      'Email': email.trim(),
      'Message': message.trim(),
      'User_ID': user.id,
    });

    final now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final uniqueName = '${now}_${i}_${file.name}';
      formData.files.add(
        MapEntry(
          'profile',
          MultipartFile.fromFileSync(file.path, filename: uniqueName),
        ),
      );
    }

    debugPrint('POST $path fields: ${formData.fields}');
    debugPrint('POST $path files: ${formData.files.length}');

    final response = await _client.post(path, data: formData);

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response data: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map<String, dynamic> &&
          data.containsKey('success') &&
          data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to submit feedback');
      }
      return;
    }

    throw Exception('Failed to submit feedback: ${response.statusCode}');
  }
}
