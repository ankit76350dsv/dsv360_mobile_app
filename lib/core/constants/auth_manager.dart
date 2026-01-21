import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:flutter/material.dart';
import 'package:zcatalyst_sdk/zcatalyst_sdk.dart';

class AuthManager {
  AuthManager._internal();
  static final AuthManager _instance = AuthManager._internal();
  static AuthManager get instance => _instance;

  ZCatalystUser? currentUser;

  /// Fetch the current user details and store them
  Future<ZCatalystUser?> fetchUser() async {
    try {
      final app = AppInitManager.instance.catalystApp;
      final (response, user) = await app.getCurrentUser();
      currentUser = user;
      debugPrint('✅ User fetched: ${user.firstName} ${user.userType}');
      return user;
    } catch (e) {
      debugPrint('❌ Failed to fetch user: $e');
      return null;
    }
  }
}
