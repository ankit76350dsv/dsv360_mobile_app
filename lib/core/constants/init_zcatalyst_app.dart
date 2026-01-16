import 'package:flutter/material.dart';
import 'package:zcatalyst_sdk/zcatalyst_sdk.dart';
import 'package:dsv360/core/constants/environment.dart';

class AppInitManager {
  AppInitManager._internal();
  static final AppInitManager _instance =
      AppInitManager._internal(); // Created only first time the object/instance
  static AppInitManager get instance =>
      _instance; // Get the same instance all time with this method

  late ZCatalystApp app;
  bool _isInitialized = false;

  /// Initialize Catalyst SDK (only once)
  Future<void> initCatalyst() async {
    if (_isInitialized) {
      debugPrint('⚠️ Catalyst SDK already initialized.');
      return;
    }

    try {
      final catalystEnv = ENVIRONMENT.environment == "DEVELOPMENT"
          ? ZCatalystEnvironment.DEVELOPMENT
          : ZCatalystEnvironment.PRODUCTION;
      await ZCatalystApp.init(environment: catalystEnv);

      app = ZCatalystApp.getInstance();
      _isInitialized = true;
      debugPrint('✅ Catalyst SDK initialized: $app');
    } catch (e) {
      debugPrint('❌ Catalyst SDK initialization failed: $e');
    }
  }

  ZCatalystApp get catalystApp {
    if (!_isInitialized) {
      throw Exception(
        "Catalyst SDK not initialized. Call initCatalyst() first.",
      );
    }
    return app;
  }
}
