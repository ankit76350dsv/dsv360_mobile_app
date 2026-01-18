import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:flutter/material.dart';

class TokenManager {
  TokenManager._internal();
  static final TokenManager _instance = TokenManager._internal();
  static TokenManager get instance => _instance;

  String? _accessToken;
  Future<String?>? _fetchingFuture;

  Future<String?> getToken() async {
    // Token already available
    if (_accessToken != null) {
      return _accessToken;
    }

    // Token fetch already in progress
    // used to prevent the race condition between many api calss
    if (_fetchingFuture != null) {
      return await _fetchingFuture;
    }

    // Start new fetch
    _fetchingFuture = _fetchTokenInternal();
    final token = await _fetchingFuture;
    _fetchingFuture = null;
    return token;
  }

  /// Fetch the current user's access token and store it
  Future<String?> _fetchTokenInternal() async {
    try {
      final app = AppInitManager.instance.catalystApp;
      // Fetch access token
      final token = await app.getAccessToken();
      _accessToken = token;
      debugPrint('✅ Access Token fetched: $token');
      return token;
    } catch (e) {
      debugPrint('❌ Failed to fetch access token: $e');
      _accessToken = null;
      return null;
    }
  }

  void clearToken() {
    _accessToken = null;
  }
}
