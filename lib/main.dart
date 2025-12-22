// lib/main.dart
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/profile/profile_page.dart';
import 'package:dsv360/views/users/users_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      
      // home: const ProfilePage(),
      // home: const DashboardPage(),
      home: const UsersPage(),
    );
  }
}
