import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/users_repository.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:dsv360/views/users/add_edit_user_page.dart';
import 'package:dsv360/views/users/user_details_page.dart';
import 'package:dsv360/views/widgets/RoleChip.dart';
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
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,

      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditUserPage(user: null)),
          );
        },
        child: Icon(
          Icons.person_add,
          size: 22, 
      ),),

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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          /// 🔍 Search field
          Expanded(
            child: TextField(
              onChanged: (value) {
                ref.read(usersSearchQueryProvider.notifier).state = value
                    .trim();
              },
              decoration: InputDecoration(
                hintText: "Search users",
                filled: true,
                fillColor: colors.surfaceVariant,
                prefixIcon: Icon(Icons.search, color: colors.onSurfaceVariant),
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

          const SizedBox(width: 12),

          /// ➕ Add User (Primary Action)
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditUserPage(user: null)),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text(
              'Add User',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserCard extends ConsumerStatefulWidget {
  final UsersModel user;
  const UserCard({super.key, required this.user});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<UserCard> {
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
    final activeUser = ref.watch(activeUserRepositoryProvider).asData?.value;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailsPage(user: widget.user)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: SizedBox(
          height: 220.00,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.user.firstName} ${widget.user.lastName}",
                            style: theme.textTheme.titleMedium,
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
                    RoleChip(text: widget.user.role),
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
                        activeUser != null && _canManageUsers(activeUser.role)
                            ? Transform.scale(
                                scale:
                                    0.85, // 👈 change this (0.7 – 1.2 usually)
                                child: Switch(
                                  value: _isActive,

                                  onChanged: (value) {
                                    setState(() {
                                      _isActive = value;
                                      // TODO: Update workStatus in backend
                                    });

                                    final message = value
                                        ? 'Employee is active'
                                        : 'Employee is inactive';

                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.info_outline,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(message),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                  },
                                ),
                              )
                            : SizedBox(),
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

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text('Re-invitation sent successfully'),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                          },
                          icon: Icon(
                            Icons.account_circle_outlined,
                            color: colors.primary,
                          ),
                          color: colors.onSurface,
                          iconSize: 20,
                        ),

                        IconButton(
                          onPressed: () {
                            // TODO: Handle edit action
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditUserPage(user: widget.user),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            color: colors.primary,
                          ),
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

  /// Centralized role rule
  bool _canManageUsers(String role) {
    return role == 'Admin' || role == 'Manager';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${widget.user.firstName} ${widget.user.lastName}?',
        ),
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
