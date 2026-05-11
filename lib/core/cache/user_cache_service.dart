import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserCacheService {
  UserCacheService._();

  static const _kUserCacheKey = 'dsv_user_cached_profile_v1';

  /// Save a minimal user map into shared preferences.
  /// Expected keys: Username, Email, UserId, Role, Phone
  static Future<void> saveUserMap(Map<String, String?> map) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(map);
    await prefs.setString(_kUserCacheKey, payload);
  }

  /// Load cached user map or null when not present.
  static Future<Map<String, String>?> loadUserMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v ?? '').toString()));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserCacheKey);
  }
}
