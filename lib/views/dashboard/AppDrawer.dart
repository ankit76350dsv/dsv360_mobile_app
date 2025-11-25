import 'package:flutter/material.dart';


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
                  _DrawerItem(icon: Icons.grid_on, label: 'Dashboard'),
                  _DrawerItem(icon: Icons.work_outline, label: 'Projects'),
                  _DrawerItem(icon: Icons.list_alt, label: 'Tasks'),
                  _DrawerItem(icon: Icons.bug_report_outlined, label: 'Issues'),
                  _DrawerItem(icon: Icons.people_outline, label: 'People'),
                  _DrawerItem(icon: Icons.settings, label: 'Settings'),
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
  const _DrawerItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Colors.white70),
    title: Text(label, style: const TextStyle(color: Colors.white70)),
    onTap: () => Navigator.pop(context),
  );
}
