import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/network/dio_client.dart';

class ProfileRepository {
  Future<String> resolveUserId() async {
    final user = AuthManager.instance.currentUser;
    if (user == null || user.id.isEmpty) {
      throw Exception('User not found. Please login again.');
    }
    return user.id;
  }

  Future<dynamic> fetchUserProfile(String userId) {
    return UserManager.instance.fetchUserProfile(userId);
  }

  Future<Response<dynamic>> uploadProfileImage({
    required String userId,
    required File croppedFile,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'profile': await MultipartFile.fromFile(
        croppedFile.path,
        filename: filename,
      ),
    });

    return ApiClient.instance.post(
      'time_entry_management_application_function/userprofile/$userId',
      data: formData,
    );
  }

  Future<Response<dynamic>> uploadBannerImage({
    required String userId,
    required String imagePath,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'cover': await MultipartFile.fromFile(
        imagePath,
        filename: filename,
      ),
    });

    return ApiClient.instance.post(
      'time_entry_management_application_function/usercover/$userId',
      data: formData,
    );
  }
}
