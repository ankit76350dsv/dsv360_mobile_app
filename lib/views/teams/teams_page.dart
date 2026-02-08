import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              title: 'Teams',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: customColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
