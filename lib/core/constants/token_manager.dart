import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:flutter/material.dart';

class TokenManager {
  TokenManager._internal();
  static final TokenManager _instance = TokenManager._internal();
  static TokenManager get instance => _instance;

  String? accessToken;

  /// Fetch the current user's access token and store it
  Future<void> fetchToken() async {
    try {
      final app = AppInitManager.instance.catalystApp;
      // Fetch access token
      final token = await app.getAccessToken();
      accessToken = token;
      debugPrint('✅ Access Token fetched: $token');
    } catch (e) {
      debugPrint('❌ Failed to fetch access token: $e');
      accessToken = null;
    }
  }
}
