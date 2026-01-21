import 'package:dsv360/core/constants/theme.dart' hide AppColors;
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';

/// Simple settings page that lets the user toggle between
/// light and dark theme modes.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              title: 'Settings',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeController.themeMode,
                builder: (context, mode, _) {
                  final isDark = mode == ThemeMode.dark;
                  return ListView(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          isDark ? 'Dark theme enabled' : 'Light theme enabled',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        value: isDark,
                        onChanged: (value) {
                          themeController.themeMode.value = value
                              ? ThemeMode.dark
                              : ThemeMode.light;
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
