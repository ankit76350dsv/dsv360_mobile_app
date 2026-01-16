// lib/main.dart
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/views/splash/splash_screen.dart';
import 'package:dsv360/views/accounts/accounts_page.dart';
import 'package:dsv360/views/badges/badges_page.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/projects/projects_screen.dart'; // project
import 'package:dsv360/views/task/tasks_screen.dart'; // task
import 'package:dsv360/views/issues/issues_screen.dart'; // issue
import 'package:dsv360/views/feedback/feedbacks_screen.dart'; // Feedbacks
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
              // home: const ProjectsScreen(),
              // home: const TasksScreen(),
              // home: const IssuesScreen(),
              // home: const FeedbacksScreen(),
              // home: const ProfilePage(),
              home: const SplashScreen(),
              // home: const AccountsPage(),
              // home: const BadgesPage(),
              // home: const UsersPage(),
              routes: {'/settings': (_) => const SettingsPage()},
            );
          },
        );
      },
    );
  }
}
