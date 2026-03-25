import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/profile/model/user_profile_model.dart';
import 'package:flutter/foundation.dart';

class UserManager {
  UserManager._internal();
  static final UserManager _instance = UserManager._internal();
  static UserManager get instance => _instance;

  UserProfileModel? userProfile;

  /// Fetch the user profile details and store them
  Future<UserProfileModel?> fetchUserProfile(String userId) async {
    try {
      final response = await ApiClient.instance.get(
        'time_entry_management_application_function/userprofile/$userId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        final rawSuccess = data['success'];
        final isSuccess = rawSuccess == true || rawSuccess == 'true';
        if (!isSuccess) return null;

        Map<String, dynamic>? profileJson;
        if (data['data'] is Map<String, dynamic>) {
          profileJson = data['data'] as Map<String, dynamic>;
        } else if (data['result'] is List &&
            (data['result'] as List).isNotEmpty &&
            (data['result'][0] as Map?)?['Users'] is Map<String, dynamic>) {
          profileJson =
              (data['result'][0]['Users'] as Map<String, dynamic>);
        }

        if (profileJson != null) {
          final profile = UserProfileModel.fromJson(profileJson);
          userProfile = profile;
          debugPrint('User Profile fetched: ${profile.userId}');
          return profile;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch user profile: $e');
      return null;
    }
  }

  void clear() {
    userProfile = null;
  }
}
