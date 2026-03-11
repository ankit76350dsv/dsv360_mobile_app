import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/views/welcome/welcome_page.dart';
import 'package:flutter/material.dart';
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
import 'package:dsv360/views/feedback/feedback_form_screen.dart';
import 'package:dsv360/views/settings/settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final customColors = Theme.of(context).custom;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8, // 80% screen
      child: Drawer(
        backgroundColor: customColors.background,
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
                        color: customColors.background,
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
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: customColors.textPrimary,
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
                              Text(
                                'DSV-360',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: customColors.logoColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    profileCardUi(context),
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
                  if (IsHaveAccess.instance.isAdmin)
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
                  if (IsHaveAccess.instance.isAdmin)
                    _DrawerItem(
                      icon: Icons.filter_alt_outlined,
                      label: 'Client Contacts',
                      subLabel: 'People & leads',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClientContactsPage(),
                          ),
                        );
                      },
                    ),
                  if (IsHaveAccess.instance.isAdmin)
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
                  if (IsHaveAccess.instance.isAdmin)
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
                      if (IsHaveAccess.instance.isAdmin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedbacksScreen(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedbackFormScreen(),
                          ),
                        );
                      }
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
                      // Show logout confirmation dialog.
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          final dc = Theme.of(ctx).custom;
                          final isDark =
                              Theme.of(ctx).brightness == Brightness.dark;
                          return Dialog(
                            backgroundColor: dc.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  Text(
                                    'You will be logged out',
                                    style: TextStyle(
                                      color: dc.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Are you sure you want to logout?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: dc.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  // Logout + Cancel buttons side by side
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: dc.textPrimary,
                                            side: BorderSide(
                                              color: isDark
                                                  ? Colors.white24
                                                  : Colors.black12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: dc.error,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                          ),
                                          child: const Text(
                                            'Logout',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      if (confirmed != true) return;

                      // Capture navigator before async operation prevents "context not mounted" issues
                      final navigator = Navigator.of(context);

                      // Close drawer first
                      navigator.pop();

                      await AppInitManager.instance.catalystApp.logout();
                      TokenManager.instance.clearToken();

                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const WelcomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(0.0),
                    ),
                  ),
                ]),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 40,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Powered by DSV360',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'DSV-360 — A unified platform to manage people, projects, and performance.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        textAlign: TextAlign.center,
                        'v1.0.0',
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
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

  Widget profileCardUi(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final userProfile = UserManager.instance.userProfile;
    final user = AuthManager.instance.currentUser;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 1, left: 6.0, right: 6.0),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: customColors.background,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0.0)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage:
                    (userProfile?.profileLink != null &&
                        userProfile!.profileLink!.isNotEmpty)
                    ? NetworkImage(userProfile.profileLink!)
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
                    color: customColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            userProfile?.username ?? 'User Name',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: customColors.textPrimary,
            ),
          ),
          Text(
            user?.role?.name ?? 'No Role',
            style: TextStyle(fontSize: 12.0, color: customColors.textSecondary),
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
    final customColors = Theme.of(context).custom;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: customColors.background,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(0.0)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              borderRadius ?? const BorderRadius.all(Radius.circular(0.0)),
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
                    Icon(icon, size: 20, color: customColors.textPrimary),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(color: customColors.textPrimary),
                        ),
                        // Text(subLabel, style: TextStyle(color: customColors.textSecondary),),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: customColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
