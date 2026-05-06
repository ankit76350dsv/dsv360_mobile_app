// lib/main.dart
//
import 'package:dsv360/core/constants/app_navigator_key.dart';
import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/splash_screen.dart';
import 'package:dsv360/features/settings/views/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitManager.instance.initCatalyst();
  await themeController.loadThemeMode();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeController.seedColor,
      builder: (context, seedColor, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController.themeMode,
          builder: (context, themeMode, _) {
            return MaterialApp(
              navigatorKey: appNavigatorKey,
              themeMode: themeMode,
              theme: buildLightTheme(themeController.seedColor.value),
              darkTheme: buildDarkTheme(themeController.seedColor.value),
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
              routes: {'/settings': (_) => const SettingsPage()},
            );
          },
        );
      },
    );
  }
}
