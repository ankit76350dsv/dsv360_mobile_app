import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:flutter/material.dart';

class TokenManager {
  TokenManager._internal();
  static final TokenManager _instance = TokenManager._internal();
  static TokenManager get instance => _instance;

  String? _accessToken;
  Future<String?>? _fetchingFuture;

  // FIX (401 intermittent error): track when the token was fetched so we can
  // proactively refresh it before it expires (~1 hour Catalyst token lifetime).
  // Refreshing at 50 min prevents the token from ever being sent expired.
  DateTime? _tokenFetchedAt;
  static const _tokenTtl = Duration(minutes: 50);

  bool get _isTokenExpired =>
      _accessToken == null ||
      _tokenFetchedAt == null ||
      DateTime.now().difference(_tokenFetchedAt!) >= _tokenTtl;

  Future<String?> getToken() async {
    // FIX: return cached token only when it is still within the safe window.
    if (!_isTokenExpired) {
      return _accessToken;
    }

    // Token fetch already in progress — wait for it (prevents race conditions).
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
      _tokenFetchedAt = DateTime.now(); // FIX: record fetch time for expiry check
      debugPrint('✅ Access Token fetched: $token');
      return token;
    } catch (e) {
      debugPrint('❌ Failed to fetch access token: $e');
      _accessToken = null;
      _tokenFetchedAt = null;
      return null;
    }
  }

  // FIX: also reset the timestamp so the next getToken() call forces a fresh fetch.
  void clearToken() {
    _accessToken = null;
    _tokenFetchedAt = null;
  }
}
