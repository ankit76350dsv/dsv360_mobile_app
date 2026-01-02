// lib/main.dart
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/people/people_page.dart';
import 'package:dsv360/views/profile/profile_page.dart';
import 'package:dsv360/views/settings/settings_page.dart';
import 'package:dsv360/views/users/users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

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
              themeMode: themeMode,
              theme: buildLightTheme(themeController.seedColor.value),
              darkTheme: buildDarkTheme(themeController.seedColor.value),
              debugShowCheckedModeBanner: false,
              // home: const PeoplePage(),
              // home: const ProfilePage(),
              // home: const DashboardPage(),
              home: const UsersPage(),
              routes: {'/settings': (_) => const SettingsPage()},
            );
          },
        );
      },
    );
  }
}
