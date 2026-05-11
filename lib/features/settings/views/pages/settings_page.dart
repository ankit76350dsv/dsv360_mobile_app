import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/dashboard/view/widgets/AppDrawer.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:flutter/material.dart';


/// Simple settings page that lets the user toggle between
/// light and dark theme modes.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        toolbarHeight: 55.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Settings',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // if needed can add the icon as well here
        // hook for info action
        // you can open a dialog or screen here
        actions: [],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                          style: TextStyle(color: customColors.textPrimary),
                        ),
                        subtitle: Text(
                          isDark ? 'Dark theme enabled' : 'Light theme enabled',
                          style: TextStyle(color: customColors.textSecondary),
                        ),
                        value: isDark,
                        onChanged: (value) async {
                          await themeController.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
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