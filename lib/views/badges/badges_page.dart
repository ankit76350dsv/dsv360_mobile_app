import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/all_badges_list.dart';
import 'package:dsv360/repositories/users_repository.dart';
import 'package:dsv360/views/badges/add_edit_badge_page.dart';
import 'package:dsv360/views/badges/assign_badges_page.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/widgets/custom_input_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as Math;

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class BadgesPage extends ConsumerStatefulWidget {
  const BadgesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BadgesPageState();
}

class _BadgesPageState extends ConsumerState<BadgesPage> {
  bool _fabOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final query = ref.watch(usersSearchQueryProvider);
    final usersAsync = ref.watch(usersRepositoryProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: const Text('DSV-360'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white12,
            child: const Icon(Icons.person_outline, size: 18),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SpeedDial(
        icon: Icons.add, // The icon for the main button
        activeIcon: Icons.close, // The icon when the menu is open
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add_alt_1),
            label: 'Add Badge',
            onTap: () {
              // open create badge
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditBadgePage()),
              );
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.badge_outlined),
            label: 'Assign Badges',
            onTap: () {
              // assign badges to user
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AssignBadgesPage()),
              );
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.emoji_events_outlined),
            label: 'Show Badges',
            onTap: () {
              // view all badges of user
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: CustomInputSearch(
                hint: "Search users",
                searchProvider: usersSearchQueryProvider,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
                child: usersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (users) {
                    final filteredUsers = users.where((u) {
                      final q = query.toLowerCase();
                      return u.firstName.toLowerCase().contains(q) ||
                          u.lastName.toLowerCase().contains(q) ||
                          u.userId.toLowerCase().contains(q) ||
                          u.emailAddress.toLowerCase().contains(q) ||
                          u.role.toLowerCase().contains(q);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return const Center(child: Text('No users found'));
                    }

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return UserBadgeCard(user: filteredUsers[index]);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserBadgeCard extends ConsumerStatefulWidget {
  final UsersModel user;
  const UserBadgeCard({super.key, required this.user});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserBadgeCardState();
}

class _UserBadgeCardState extends ConsumerState<UserBadgeCard> {
  late bool _isActive;
  late String verificationStatusText;
  late IconData verificationStatusIcon;
  late Color verificationStatusColor;

  @override
  void initState() {
    super.initState();
    _isActive = widget.user.workStatus == WorkStatus.active;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeUser = ref.watch(activeUserRepositoryProvider).asData?.value;

    return GestureDetector(
      onTap: () {},
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2), // 👈 border color
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.user.firstName} ${widget.user.lastName}",
                              style: theme.textTheme.bodyLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2.0),
                            _userInfoRow(Icons.email, widget.user.emailAddress),
                            _userInfoRow(Icons.tag, widget.user.userId),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: _openUserBadges,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colors.tertiary.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 18,
                                color: colors.tertiary.withOpacity(0.3),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "BADGES",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: colors.tertiary.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInfoRow(IconData icon, String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.tertiary),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  void _openUserBadges() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _UserBadgesSheet(user: widget.user);
      },
    );
  }
}

class _UserBadgesSheet extends ConsumerWidget {
  final UsersModel user;
  const _UserBadgesSheet({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    // 🔥 TEMP: Replace later with real API badges for this user
    final badgesAsync = ref.watch(allDSVBadgesListRepositoryProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                padding: const EdgeInsets.only(top: 14, bottom: 12),
                alignment: Alignment.center,
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.tertiary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              Text(
                "${user.firstName}'s Badges",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 16),

              //
              Expanded(
                child: badgesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (err, _) => Center(
                    child: Text(
                      err.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                  data: (badges) {
                    final assignedBadges = badges.take(6).toList();

                    if (assignedBadges.isEmpty) {
                      return const Center(child: Text("No badges assigned"));
                    }

                    return GridView.builder(
                      controller: scrollController,
                      itemCount: assignedBadges.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        final badge = assignedBadges[index];

                        return Column(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: Stack(
                                children: [
                                  // Glass card
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(200),
                                      side: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 2.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Image.network(
                                        badge.badgeLogo,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.verified,
                                              color: Colors.greenAccent,
                                              size: 36,
                                            ),
                                      ),
                                    ),
                                  ),

                                  // Remove button
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () {
                                        // remove badge
                                      },
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: colors.error,
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: colors.error,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 6),
                            Text(
                              badge.badgeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black),
                            ),
                            Text(
                              badge.badgeLevel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              SafeArea(
                top: false, // we only care about bottom inset
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "close".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _LoadingView(ColorScheme colors) {
  return SizedBox(
    height: 200,
    child: Center(child: CircularProgressIndicator(color: colors.primary)),
  );
}

Widget _ErrorView(String message, ColorScheme colors) {
  return SizedBox(
    height: 200,
    child: Center(
      child: Text(message, style: TextStyle(color: colors.error)),
    ),
  );
}

Widget _NoTasksView(ColorScheme colors) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      'This user has no pending tasks.\nYou can safely delete the user.',
      style: TextStyle(color: colors.onSurfaceVariant),
    ),
  );
}

Widget _DragHandle(ColorScheme colors) {
  return Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.outlineVariant,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
