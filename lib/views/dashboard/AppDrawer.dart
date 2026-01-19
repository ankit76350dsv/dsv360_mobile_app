import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/projects/projects_screen.dart';
import 'package:dsv360/views/task/tasks_screen.dart';
import 'package:dsv360/views/issues/issues_screen.dart';
import 'package:dsv360/views/accounts/accounts_page.dart';
import 'package:dsv360/views/clients/client_contacts_page.dart';
import 'package:dsv360/views/badges/badges_page.dart';
import 'package:dsv360/views/users/users_page.dart';
import 'package:dsv360/views/people/people_page.dart';
import 'package:dsv360/views/teams/teams_page.dart';
import 'package:dsv360/views/ai/dsv_ai_page.dart';
import 'package:dsv360/views/feedback/feedbacks_screen.dart';
import 'package:dsv360/views/settings/settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: const [
                  Icon(Icons.cloud, size: 36, color: AppColors.textPrimary),
                  SizedBox(width: 12),
                  Text(
                    'DSV-360',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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
                    onTap: () {
                      // For Dashboard, we DO want to close the drawer and go to root
                      Navigator.pop(context);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.work_outline,
                    label: 'Projects',
                    onTap: () {
                      // Do NOT close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.list_alt,
                    label: 'Tasks',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TasksScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.bug_report_outlined,
                    label: 'Issues',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IssuesScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.apartment,
                    label: 'Accounts',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AccountsPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.filter_alt,
                    label: 'Client Contacts',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ClientContactsPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.verified,
                    label: 'Badges',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BadgesPage()),
                      );
                    },
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
                    icon: Icons.groups,
                    label: 'Teams',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TeamsPage()),
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
                    icon: Icons.feedback_outlined,
                    label: 'Feedback',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FeedbacksScreen()),
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
              child: Text('v1.0.0', style: TextStyle(color: AppColors.textHint)),
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
    leading: Icon(icon, color: AppColors.textSecondary),
    title: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
    onTap: () {
      // Navigator.pop(context); // Handled by parent
      onTap();
    },
  );
}
