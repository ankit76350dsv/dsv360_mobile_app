import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/profile/model/user_profile_model.dart';
import 'package:dsv360/features/profile/repositories/user_cache_repository.dart';

final userCacheProvider = StateNotifierProvider<UserCacheNotifier, UserProfileModel?>((ref) {
  return UserCacheNotifier();
});

class UserCacheNotifier extends StateNotifier<UserProfileModel?> {
  UserCacheNotifier() : super(null) {
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    final map = await UserCacheRepository.loadUserMap();
    if (map == null) return;
    // Map keys: Username, Email, UserId, Role, Phone
    final user = UserProfileModel(
      address: '',
      aboutMe: '',
      resumeId: '',
      teamName: '',
      teamId: '',
      roleId: map['Role'] ?? '',
      orgId: '',
      reporterImage: '',
      skills: '',
      phone: map['Phone'] ?? '',
      countryCode: '',
      shiftEndTime: '',
      creatorId: '',
      reporterName: map['Username'] ?? '',
      reporterId: '',
      resumeLink: '',
      coverLink: '',
      shiftStartTime: '',
      modifiedTime: '',
      username: map['Username'] ?? '',
      createdTime: '',
      userId: map['UserId'] ?? '',
      profileLink: '',
      empId: '',
      rowId: '',
      location: '',
    );
    state = user;
  }

  Future<void> saveCachedUser({required String username, String? email, required String userId, String? role, String? phone}) async {
    final map = <String, String?>{
      'Username': username,
      'Email': email ?? '',
      'UserId': userId,
      'Role': role ?? '',
      'Phone': phone ?? '',
    };
    await UserCacheRepository.saveUserMap(map);
    await _loadFromCache();
  }

  Future<void> clearCache() async {
    await UserCacheRepository.clear();
    state = null;
  }
}
