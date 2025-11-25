// lib/main.dart
import 'dart:math';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/profile/profile_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF0EA084)),
      
      home: const ProfilePage(),
      // home: const DashboardPage(),
    );
  }
}
