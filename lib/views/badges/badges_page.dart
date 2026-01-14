import 'package:flutter/material.dart';
import 'package:dsv360/views/widgets/custom_app_bar.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Badges'),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
