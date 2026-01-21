import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:dsv360/core/services/auth_service.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/feedback/feedback_form_screen.dart';
import 'package:dsv360/views/welcome/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/app_colors.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Removed dependency on Theme.of(context).colorScheme for colors
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8, // 80% screen
      child: Drawer(
        backgroundColor: AppColors.background, // Explicit drawer background
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      height: 56, // standard app bar height
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 🔙 Back button (left)
                          Positioned(
                            left: 0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),

                          // 🖼️ Logo + Title (centered)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/dsv.png",
                                width: 40,
                                height: 50,
                                fit: BoxFit.fitWidth,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'DSV-360',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    profileCardUi(context, ref),
                  ],
                ),
              ),

              // Menu items
              SliverList(
                delegate: SliverChildListDelegate([
                  _DrawerItem(
                    icon: Icons.grid_on,
                    label: 'Dashboard',
                    subLabel: 'Overview & stats',
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(0.0),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.work_outline,
                    label: 'Projects',
                    subLabel: 'Manage ongoing work',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProjectsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.list_alt,
                    label: 'Tasks',
                    subLabel: 'Your assigned tasks',
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
                    subLabel: 'Track & resolve bugs',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IssuesScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.apartment_outlined,
                    label: 'Accounts',
                    subLabel: 'Client organizations',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AccountsPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.filter_alt_outlined,
                    label: 'Client Contacts',
                    subLabel: 'People & leads',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ClientContactsPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.verified_outlined,
                    label: 'Badges',
                    subLabel: 'Achievements & rewards',
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
                    subLabel: 'Manage employees',
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
                    subLabel: 'Team directory',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PeoplePage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.groups_outlined,
                    label: 'Teams',
                    subLabel: 'Group collaboration',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TeamsPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.smart_toy_outlined,
                    label: 'DSV AI',
                    subLabel: 'Smart assistant',
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
                    subLabel: 'User suggestions',
                    onTap: () {
                      final isAdmin = AuthService().isAdmin;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => isAdmin
                              ? const FeedbacksScreen()
                              : const FeedbackFormScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    subLabel: 'App preferences',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    subLabel: 'Sign out of your account',
                    onTap: () async {
                      // Close drawer first
                      Navigator.pop(context);

                      await AppInitManager.instance.catalystApp.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const WelcomePage(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(0.0),
                    ),
                  ),
                ]),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    children: [
                      Text(
                        'Made by DSV-360',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Text(
                        'DSV-360 — A unified platform to manage people, projects, and performance.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12, // bodySmall approximation
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        textAlign: TextAlign.center,
                        'v1.0.0',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12, // bodySmall approximation
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileCardUi(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final activeUser = ref.watch(activeUserRepositoryProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 1, left: 6.0, right: 6.0),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0.0)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage:
                    (activeUser != null &&
                        activeUser.profilePic != null &&
                        activeUser.profilePic!.isNotEmpty)
                    ? NetworkImage(activeUser.profilePic!)
                    : const AssetImage("assets/icons/profile.png")
                          as ImageProvider,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardBackground, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "${activeUser?.firstName} ${activeUser?.lastName}",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "${activeUser?.roleName}",
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final BorderRadius? borderRadius;
  final VoidCallback onTap;

  const _DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(0.0)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(0.0)),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 14.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        // Text(subLabel, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
