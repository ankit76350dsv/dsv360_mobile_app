import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/settings/settings_page.dart';
import 'package:dsv360/views/users/users_page.dart';
import 'package:dsv360/views/ai/dsv_ai_page.dart';
import 'package:flutter/material.dart';
import 'package:dsv360/views/people/people_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF0B0C0D),
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: const [
                  Icon(Icons.cloud, size: 36),
                  SizedBox(width: 12),
                  Text(
                    'DSV-360',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _DrawerItem(
                    icon: Icons.grid_on,
                    label: 'Dashboard',
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DashboardPage()),
                      )
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.work_outline,
                    label: 'Projects',
                    onTap: () => {},
                  ),
                  _DrawerItem(
                    icon: Icons.list_alt,
                    label: 'Tasks',
                    onTap: () => {},
                  ),
                  _DrawerItem(
                    icon: Icons.bug_report_outlined,
                    label: 'Issues',
                    onTap: () => {},
                  ),
                  _DrawerItem(
                    icon: Icons.person_add_outlined,
                    label: 'Users',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => UsersPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    label: 'People',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PeoplePage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.smart_toy,
                    label: 'DSV AI',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DsvAiPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('v1.0.0', style: TextStyle(color: Colors.white30)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function onTap;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Colors.white70),
    title: Text(label, style: const TextStyle(color: Colors.white70)),
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
  );
}
