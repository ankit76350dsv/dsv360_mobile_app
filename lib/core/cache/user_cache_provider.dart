import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/profile/repositories/user_cache_repository.dart';

/// Lightweight global user model used by the provider.
class GlobalUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String firstName;
  final String lastName;
  final String orgId;

  GlobalUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.firstName = '',
    this.lastName = '',
    this.orgId = '',
  });

  factory GlobalUser.fromMap(Map<String, String> map) {
    return GlobalUser(
      id: map['UserId'] ?? '',
      name: map['Username'] ?? '',
      email: map['Email'] ?? '',
      role: map['Role'] ?? '',
      phone: map['Phone'] ?? '',
      firstName: map['FirstName'] ?? '',
      lastName: map['LastName'] ?? '',
      orgId: map['OrgId'] ?? '',
    );
  }

  Map<String, String> toMap() => {
        'UserId': id,
        'Username': name,
        'Email': email,
        'Role': role,
        'Phone': phone,
        'FirstName': firstName,
        'LastName': lastName,
        'OrgId': orgId,
      };
}

/// StateNotifier that keeps the global user and loads it from shared prefs on init.
class GlobalUserNotifier extends StateNotifier<GlobalUser?> {
  GlobalUserNotifier() : super(null) {
    _init();
  }

  Future<void> _init() async {
    try {
      final map = await UserCacheRepository.loadUserMap();
      if (map != null) {
        state = GlobalUser.fromMap(map);
      }
    } catch (_) {
      // ignore errors and keep null state
    }
  }

  /// Force reload from underlying cache (shared prefs).
  Future<void> refresh() async {
    await _init();
  }

  /// Save and set current global user both in memory and in cache.
  Future<void> setUser(GlobalUser user) async {
    state = user;
    try {
      await UserCacheRepository.saveUserMap(user.toMap());
    } catch (_) {}
  }

  Future<void> clear() async {
    state = null;
    try {
      await UserCacheRepository.clear();
    } catch (_) {}
  }
}

/// Public provider to access current global user. Usage in widgets:
/// final globalUser = ref.watch(globalUserProvider);
/// then `globalUser?.id`, `globalUser?.name`, etc.
final globalUserProvider = StateNotifierProvider<GlobalUserNotifier, GlobalUser?>((ref) {
  return GlobalUserNotifier();
});
