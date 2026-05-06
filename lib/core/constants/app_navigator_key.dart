import 'package:flutter/widgets.dart';

/// A global navigator key that allows navigation from anywhere in the app
/// (including Dio interceptors, singletons, etc.) without needing a
/// BuildContext.
///
/// Usage: pass to MaterialApp(navigatorKey: appNavigatorKey) in main.dart.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
