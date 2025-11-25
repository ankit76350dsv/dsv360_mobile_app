import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      // After splash, go to home
      GoRouter.of(context).go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.analytics_outlined, size: 82),
          SizedBox(height: 12),
          Text('DSV-360', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Human Resource Management', style: TextStyle(color: Colors.white70)),
        ]),
      ),
    );
  }
}
