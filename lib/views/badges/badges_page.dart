import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/all_badges_list.dart';
import 'package:dsv360/repositories/users_repository.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BadgesPage extends ConsumerStatefulWidget {
  const BadgesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BadgesPageState();
}

class _BadgesPageState extends ConsumerState<BadgesPage> {
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
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {},
        child: Icon(Icons.person_add, size: 22),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: TextField(
                onChanged: (value) {
                  ref.read(usersSearchQueryProvider.notifier).state = value
                      .trim();
                },
                decoration: InputDecoration(
                  hintText: "Search users",
                  filled: true,
                  fillColor: colors.surfaceVariant,
                  prefixIcon: Icon(
                    Icons.search,
                    color: colors.onSurfaceVariant,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: UserBadgeCard(user: filteredUsers[index]),
                        );
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.user.userId,
                          style: TextStyle(color: theme.colorScheme.surface),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withOpacity(0.2),
            ),

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
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _openUserBadges();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("BADGES"),
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
    final assignedBadges =
        ref
            .watch(allDSVBadgesListRepositoryProvider)
            .asData
            ?.value
            .take(6)
            .toList() ??
        [];

return DraggableScrollableSheet(
  expand: false,
  initialChildSize: 0.7,
  minChildSize: 0.4,
  maxChildSize: 0.95,
  builder: (context, scrollController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          Text(
            "${user.firstName}'s Badges",
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          // 🔥 THIS is now safe
          Expanded(
            child: GridView.builder(
              controller: scrollController, // IMPORTANT
              itemCount: assignedBadges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final badge = assignedBadges[index];

                return Column(
                  children: [
                    SizedBox(
  width: 72,
  height: 72,
  child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: badge.badgeLogo.isNotEmpty
    ? Image.network(
        badge.badgeLogo,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.verified,
          size: 40,
          color: Colors.green,
        ),
      )
    : const Icon(
        Icons.verified,
        size: 40,
        color: Colors.green,
      ),

                        ),

                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              // remove badge
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        )
                      ],)
                    ),
                    const SizedBox(height: 6),
                    Text(badge.badgeName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      badge.badgeId,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
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
