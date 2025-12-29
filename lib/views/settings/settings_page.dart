import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:flutter/material.dart';

/// Simple settings page that lets the user toggle between
/// light and dark theme modes.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Settings')),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: appThemeModeNotifier,
        builder: (context, mode, _) {
          final isDark = mode == ThemeMode.dark;
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(
                  isDark ? 'Dark theme enabled' : 'Light theme enabled',
                ),
                value: isDark,
                onChanged: (value) {
                  appThemeModeNotifier.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
