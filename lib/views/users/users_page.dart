import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/users_repository.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:dsv360/views/users/user_details_page.dart';
import 'package:dsv360/views/widgets/VerificationStatusChip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersRepositoryProvider);
    final query = ref.watch(usersSearchQueryProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('DSV-360'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
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
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: usersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (users) {

                    final filteredUsers = users.where((u) {
                      final q = query.toLowerCase();
                      return u.name.toLowerCase().contains(q) ||
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
                          child: UserCard(user: users[index]),
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

class _Header extends ConsumerWidget {
  const _Header({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.onPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.people, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                "Users",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) {
              ref.read(usersSearchQueryProvider.notifier).state =
                  value.trim();
            },
            decoration: InputDecoration(
              hintText: "Search Users",
              filled: true,
              fillColor: colors.surface.withOpacity(0.85),
              prefixIcon: Icon(Icons.search, color: colors.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class UserCard extends StatefulWidget {
  final UsersModel user;

  const UserCard({super.key, required this.user});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.user.workStatus == WorkStatus.active;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailsPage(user: widget.user)),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.outlineVariant, width: 1),
        ),
        color: colors.surface,
        child: SizedBox(
          height: 220.00,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.outline, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: colors.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 28,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.user.userId,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _RoleChip(text: widget.user.role),
                    VerificationStatusChip(
                      status: widget.user.verificationStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                              // TODO: Update workStatus in backend
                            });
                          },
                          activeColor: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: _isActive
                                ? colors.primary
                                : colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // TODO: Handle user card action
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UserDetailsPage(user: widget.user),
                              ),
                            );
                          },
                          icon: const Icon(Icons.account_circle_outlined),
                          color: colors.onSurface,
                          iconSize: 20,
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Handle edit action
                          },
                          icon: const Icon(Icons.edit_outlined),
                          color: colors.onSurface,
                          iconSize: 20,
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Handle delete action
                            _showDeleteConfirmation(context);
                          },
                          icon: const Icon(Icons.delete_outline),
                          color: colors.error,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${widget.user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String text;

  const _RoleChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Chip(
      label: Text(
        text,
        style: TextStyle(fontSize: 14, color: colors.onSecondaryContainer),
      ),
      backgroundColor: colors.secondaryContainer,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
