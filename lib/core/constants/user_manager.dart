import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/profile/model/user_profile_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dsv360/features/profile/repositories/user_cache_repository.dart';
import 'package:dsv360/core/constants/auth_manager.dart';

class UserManager {
  UserManager._internal();
  static final UserManager _instance = UserManager._internal();
  static UserManager get instance => _instance;

  UserProfileModel? userProfile;

  /// Fetch the user profile details and store them
  Future<UserProfileModel?> fetchUserProfile(String userId) async {
    // Try to load the cached profile first so UI can show something immediately.
    try {
      final cached = await UserCacheRepository.loadUserMap();
      if (cached != null) {
        userProfile = UserProfileModel(
          address: '',
          aboutMe: '',
          resumeId: '',
          teamName: '',
          teamId: '',
          roleId: cached['Role'] ?? '',
          orgId: '',
          reporterImage: '',
          skills: '',
          phone: cached['Phone'] ?? '',
          countryCode: '',
          shiftEndTime: '',
          creatorId: '',
          reporterName: cached['Username'] ?? '',
          reporterId: '',
          resumeLink: '',
          coverLink: '',
          shiftStartTime: '',
          modifiedTime: '',
          username: cached['Username'] ?? '',
          createdTime: '',
          userId: cached['UserId'] ?? userId,
          profileLink: '',
          empId: '',
          rowId: '',
          location: '',
        );
      }
    } catch (_) {}
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

          // Persist user values to local cache for quick access (includes
          // offline-required fields: firstName, lastName, orgId).
          try {
            final catalystUser = AuthManager.instance.currentUser;
            final map = <String, String?>{
              'Username': profile.username,
              'Email': catalystUser?.emailId ?? '',
              'UserId': profile.userId,
              'Role': catalystUser?.role?.name ?? profile.roleId,
              'Phone': profile.phone,
              'FirstName': catalystUser?.firstName ?? '',
              'LastName': catalystUser?.lastName ?? '',
              'OrgId': catalystUser?.zaaid.toString() ?? '',
            };
            await UserCacheRepository.saveUserMap(map);
          } catch (_) {}

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
