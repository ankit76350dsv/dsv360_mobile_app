import 'package:dsv360/models/task.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/task_repository.dart';
import 'package:dsv360/repositories/users_repository.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:dsv360/views/users/add_edit_user_page.dart';
import 'package:dsv360/views/users/user_details_page.dart';
import 'package:dsv360/views/widgets/RoleChip.dart';
import 'package:dsv360/views/widgets/VerificationStatusChip.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
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
    final colors = Theme.of(context).colorScheme;

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditUserPage(user: null)),
          );
        },
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
                          child: UserCard(user: filteredUsers[index]),
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
                            _showDeleteUserSheet(
                              context,
                              user: widget.user, // List<Task>
                            );
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

  void _showDeleteUserSheet(BuildContext context, {required UsersModel user}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _DeleteUserBottomSheet(user: user);
      },
    );
  }
}

class _DeleteUserBottomSheet extends ConsumerStatefulWidget {
  final UsersModel user;

  const _DeleteUserBottomSheet({required this.user});

  @override
  ConsumerState<_DeleteUserBottomSheet> createState() =>
      _DeleteUserBottomSheetState();
}

class _DeleteUserBottomSheetState
    extends ConsumerState<_DeleteUserBottomSheet> {
  final Map<String, String> reassignment = {};

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tasksAsync = ref.watch(taskRepositoryProvider);
    // 👆 ideally scoped by userId

    return SafeArea(
      top: true,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: tasksAsync.when(
            loading: () => _LoadingView(colors),
            error: (e, _) => _ErrorView(e.toString(), colors),
            data: (tasks) {
              final hasPendingTasks = tasks.isNotEmpty;

              return Column(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DragHandle(colors),

                  Text(
                    hasPendingTasks ? 'Task Assignment' : 'No Tasks Pending?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  if (!hasPendingTasks)
                    _NoTasksView(colors)
                  else
                    _TaskAssignmentView(
                      tasks: tasks,
                      reassignment: reassignment,
                      onChanged: () => setState(() {}),
                    ),

                  const SizedBox(height: 20),

                  BottomTwoButtons(
                    button1Text: "Cancel",
                    button2Text: "DELETE USER",
                    button1Function: () {
                      Navigator.pop(context);
                    },
                    button2Function: () {
                      (!hasPendingTasks || reassignment.length == tasks.length)
                          ? () {
                              Navigator.pop(context);
                            }
                          : null;
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
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

class _TaskAssignmentView extends StatelessWidget {
  final List<Task> tasks;
  final Map<String, String> reassignment;
  final VoidCallback onChanged;

  const _TaskAssignmentView({
    required this.tasks,
    required this.reassignment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: tasks.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              /// Task name
              Expanded(
                child: Text(
                  task.taskName,
                  style: TextStyle(color: colors.onSurface),
                ),
              ),
              const SizedBox(width: 12),

              /// Employee selector
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: reassignment[task.taskName], // ✅ bind value
                  hint: const Text('Select Employee'),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Aman')),
                    DropdownMenuItem(value: '2', child: Text('Riya')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    // ✅ STORE assignment
                    reassignment[task.taskName] = value;

                    // ✅ notify parent
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
