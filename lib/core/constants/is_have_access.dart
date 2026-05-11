import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/cache/user_cache_service.dart';

class IsHaveAccess {
  IsHaveAccess._internal();
  static final IsHaveAccess _instance = IsHaveAccess._internal();
  static IsHaveAccess get instance => _instance;

  /// Role name from live SDK user, or empty string when offline.
  String get _roleName =>
      AuthManager.instance.currentUser?.role?.name ?? '';

  /// Async role — reads from SharedPrefs when the live user is unavailable.
  Future<String> _roleNameAsync() async {
    final live = AuthManager.instance.currentUser?.role?.name;
    if (live != null && live.isNotEmpty) return live;
    final cached = await UserCacheService.loadUserMap();
    return cached?['Role'] ?? '';
  }

  bool get isAdmin => _roleName == 'Admin';

  bool get isManager =>
      _roleName.toLowerCase().contains('manager');

  /// Offline-safe async versions used where a Future is acceptable.
  Future<bool> get isAdminAsync async =>
      (await _roleNameAsync()) == 'Admin';

  Future<bool> get isManagerAsync async =>
      (await _roleNameAsync()).toLowerCase().contains('manager');
}
