import 'package:dsv360/core/cache/user_cache_service.dart';
import 'package:dsv360/features/profile/model/user_profile_model.dart';

class UserCacheRepository {
  UserCacheRepository._();

  static Future<void> saveUserProfileToCache(UserProfileModel profile) async {
    final map = <String, String?>{
      'Username': profile.username,
      'Email': null,
      'UserId': profile.userId,
      'Role': profile.roleId,
      'Phone': profile.phone,
    };

    // Email may come from AuthManager in some places; repository caller can set it
    await UserCacheService.saveUserMap(map);
  }

  static Future<void> saveUserMap(Map<String, String?> map) async {
    await UserCacheService.saveUserMap(map);
  }

  static Future<Map<String, String>?> loadUserMap() async {
    return await UserCacheService.loadUserMap();
  }

  static Future<void> clear() async {
    await UserCacheService.clear();
  }
}
