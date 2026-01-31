import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/user_profile_model.dart';
import 'package:flutter/foundation.dart';

class UserManager {
  UserManager._internal();
  static final UserManager _instance = UserManager._internal();
  static UserManager get instance => _instance;

  UserProfileModel? userProfile;

  /// Fetch the user profile details and store them
  Future<UserProfileModel?> fetchUserProfile(String userId) async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/userprofile/$userId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == "true" && data['data'] != null) {
          final profile = UserProfileModel.fromJson(data['data']);
          userProfile = profile;
          debugPrint('✅ User Profile fetched: ${profile.userId} ✅');
          return profile;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to fetch user profile: $e');
      return null;
    }
  }

  void clear() {
    userProfile = null;
  }
}
