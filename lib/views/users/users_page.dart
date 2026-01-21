import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/task.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/pending_tasks_repository.dart';
import 'package:dsv360/repositories/task_repository.dart';
import 'package:dsv360/repositories/users_repository.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:dsv360/views/users/add_edit_user_page.dart';
import 'package:dsv360/views/users/user_details_page.dart';
import 'package:dsv360/views/widgets/app_snackbar.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_search.dart';
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
        toolbarHeight: 35.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Users',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // if needed can add the icon as well here
        // hook for info action
        // you can open a dialog or screen here
        actions: [],
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
                vertical: 8.0,
              ),
              child: CustomInputSearch(
                searchProvider: usersSearchQueryProvider,
                hint: "Search users",
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
                        return UserCard(
                          user: filteredUsers[index],
                          userList: users,
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
  final List<UsersModel> userList;
  const UserCard({super.key, required this.user, required this.userList});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<UserCard> {
  late String verificationStatusText;
  late IconData verificationStatusIcon;
  late Color verificationStatusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final verificationStatus = widget.user.verificationStatus;
    final isActive = widget.user.workStatus == WorkStatus.active;

    switch (verificationStatus) {
      case VerificationStatus.verified:
        verificationStatusText = "Verified";
        verificationStatusIcon = Icons.verified;
        verificationStatusColor = Colors.green;
        break;
      case VerificationStatus.pending:
        verificationStatusText = "Pending";
        verificationStatusIcon = Icons.hourglass_top;
        verificationStatusColor = Colors.orange;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailsPage(user: widget.user)),
        );
      },
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
                          "U${widget.user.userId.substring(widget.user.userId.length - 4)}",
                          style: TextStyle(color: theme.colorScheme.surface),
                        ),
                      ),
                      const Spacer(),
                      CustomChip(
                        label: widget.user.role,
                        color: colors.primary,
                        icon: null,
                      ),
                      const SizedBox(width: 6.0),
                      CustomChip(
                        label: verificationStatusText,
                        color: verificationStatusColor,
                        icon: verificationStatusIcon,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 38,
                            height: 18,
                            child: Transform.scale(
                              scale: 0.70,
                              child: Switch(
                                value: isActive,
                                onChanged: (value) async {
                                  // this value is after toggling value

                                  // Optional: show loading indicator or disable switch
                                  try {
                                    // Call API based on switch value
                                    final path = value
                                        // to make it active (now value is true, previous was false)
                                        ? '/server/time_entry_management_application_function/employee/DISABLED/${widget.user.userId}'

                                        // to make it inactive (now value is false, previous was true)
                                        : '/server/time_entry_management_application_function/employee/ACTIVE/${widget.user.userId}';
                                    await DioClient.instance.post(path);

                                    AppSnackBar.show(
                                      context,
                                      message: value
                                          ? 'Employee is active'
                                          : 'Employee is inactive',
                                    );

                                    // Refresh users provider (sync with backend)
                                    ref.invalidate(usersRepositoryProvider);
                                  } catch (e) {
                                    AppSnackBar.show(
                                      context,
                                      message: 'Failed to update work status',
                                      icon: Icons.error_outline,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: isActive
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
                          widget.user.verificationStatus != VerificationStatus.verified
                          ?
                          CustomCardButton(
                            icon: Icons.account_circle,
                            onTap: () async {
                              try {
                                await DioClient.instance.post(
                                  '/server/time_entry_management_application_function/reInviteEmployees',
                                  data: {
                                    'email_id': widget.user.emailAddress
                                        .toString(),
                                    'first_name': widget.user.firstName
                                        .toString(),
                                    'last_name': widget.user.lastName
                                        .toString(),
                                    'role_id': widget.user.roleId.toString(),
                                    'user_id': widget.user.userId.toString(),
                                  },
                                );

                                AppSnackBar.show(
                                  context,
                                  message: 'Re-invitation sent successfully',
                                );
                              } catch (e) {
                                debugPrint('❌ Failed to sent invitation: $e');

                                AppSnackBar.show(
                                  context,
                                  message: 'Failed to sent re-invitation.',
                                );
                              }
                            },
                          )
                          :
                          // nothing
                          SizedBox(),
                          
                          const SizedBox(width: 5.0),
                          CustomCardButton(
                            icon: Icons.edit,
                            onTap: () {
                              // TODO: Handle edit action
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditUserPage(user: widget.user),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 5.0),
                          CustomCardButton(
                            icon: Icons.delete,
                            onTap: () {
                              _showDeleteUserSheet(
                                context,
                                user: widget.user, // List<Task>
                                usersList: widget.userList,
                              );
                            },
                            color: colors.error,
                          ),
                        ],
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

  /// Centralized role rule
  bool _canManageUsers(String role) {
    // return role.contains('Admin') || role.contains('Manager');
    return true;
  }

  void _showDeleteUserSheet(
    BuildContext context, {
    required UsersModel user,
    required List<UsersModel> usersList,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: false,
      builder: (_) {
        return _DeleteUserBottomSheet(user: user, usersList: usersList);
      },
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
}

class _DeleteUserBottomSheet extends ConsumerStatefulWidget {
  final UsersModel user;
  final List<UsersModel> usersList;

  const _DeleteUserBottomSheet({required this.user, required this.usersList});

  @override
  ConsumerState<_DeleteUserBottomSheet> createState() =>
      _DeleteUserBottomSheetState();
}

class _DeleteUserBottomSheetState
    extends ConsumerState<_DeleteUserBottomSheet> {
  final Map<String, String> reassignment = {};

  List<Map<String, dynamic>> _buildReassignmentPayload(
    List<Task> tasks,
    Map<String, String> reassignment,
    List<UsersModel> users,
  ) {
    return tasks.map((task) {
      final assignedUserId = reassignment[task.taskId];

      final assignedUser = users.firstWhere((u) => u.userId == assignedUserId);

      return {
        "Task_ID": task.taskId,
        "assigned_To_Id": assignedUser.userId,
        "assigned_To": '${assignedUser.firstName} ${assignedUser.lastName}'
            .trim(),
      };
    }).toList();
  }

  String bottomTwoButtonsLoadingKey = 'delete_user_sheet_key';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pendingTasksAsync = ref.watch(
      pendingTasksListRepositoryProvider(widget.user.userId),
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Always visible
            _dragHandle(colors),

            const SizedBox(height: 8),

            // ✅ Async-controlled content
            pendingTasksAsync.when(
              loading: () => _LoadingView(colors),
              error: (e, _) => _ErrorView(e.toString(), colors),
              data: (tasks) {
                final hasPendingTasks = tasks.isNotEmpty;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPendingTasks ? 'Task Assignment' : 'No Tasks Pending?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    if (!hasPendingTasks)
                      _noTasksView(colors)
                    else
                      _TaskAssignmentView(
                        tasks: tasks,
                        users: widget.usersList,
                        currentUser: widget.user,
                        reassignment: reassignment,
                        onChanged: () => setState(() {}),
                      ),

                    const SizedBox(height: 20),

                    BottomTwoButtons(
                      loadingKey: bottomTwoButtonsLoadingKey,
                      button1Text: "Cancel",
                      button2Text: "delete user",
                      button1Function: () {
                        Navigator.pop(context);
                      },
                      button2Function: () async {
                        // Block only when pending tasks exist but reassignment is incomplete
                        if (hasPendingTasks &&
                            reassignment.length != tasks.length) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please reassign all tasks before deleting the user',
                              ),
                            ),
                          );
                          return;
                        }

                        ref
                                .read(
                                  submitLoadingProvider(
                                    bottomTwoButtonsLoadingKey,
                                  ).notifier,
                                )
                                .state =
                            true;

                        // ALWAYS build payload (empty [] if no tasks)
                        final reassignmentPayload = _buildReassignmentPayload(
                          tasks,
                          reassignment,
                          widget.usersList,
                        );

                        debugPrint(
                          'Reassignment payload: $reassignmentPayload',
                        );

                        try {
                          // ALWAYS hit delete API
                          await DioClient.instance.post(
                            '/server/time_entry_management_application_function/employee/${widget.user.userId}',
                            data: reassignmentPayload,
                          );

                          Navigator.pop(context, true);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User deleted successfully.'),
                            ),
                          );

                          ref.invalidate(usersRepositoryProvider);
                        } catch (e) {
                          debugPrint('❌ Failed to delete user: $e');

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to delete user'),
                            ),
                          );
                        } finally {
                          ref
                                  .read(
                                    submitLoadingProvider(
                                      bottomTwoButtonsLoadingKey,
                                    ).notifier,
                                  )
                                  .state =
                              false;
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
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

Widget _noTasksView(ColorScheme colors) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      'This user has no pending tasks.\nYou can safely delete the user.',
      style: TextStyle(color: colors.onSurfaceVariant),
    ),
  );
}

Widget _dragHandle(ColorScheme colors) {
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
  final List<UsersModel> users;
  final UsersModel currentUser;
  final Map<String, String> reassignment;
  final VoidCallback onChanged;

  const _TaskAssignmentView({
    super.key,
    required this.tasks,
    required this.users,
    required this.currentUser,
    required this.reassignment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    tasks.forEach((task) {
      debugPrint('TaskId: ${task.taskId}, TaskName: ${task.taskName}');
    });

    final assignableUsers = users
        .where((u) => u.userId != currentUser.userId)
        .toList();

    final options = assignableUsers.map((u) {
      return DropdownMenuItem<String>(
        value: u.userId,
        child: Text('${u.firstName} ${u.lastName}'.trim()),
      );
    }).toList();

    return Column(
      children: tasks.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Task name
              Text(
                "Task Name: ${task.taskName}",
                textAlign: TextAlign.left,
                style: TextStyle(color: colors.onSurface),
              ),
              const SizedBox(height: 6),

              /// Employee selector
              CustomDropDownField(
                key: ValueKey(task.taskId),
                options: options,
                selectedOption: reassignment[task.taskId],
                hintText: "Employee",
                labelText: "Reassign to",
                prefixIcon: Icons.person,
                onChanged: (value) {
                  if (value == null) return;

                  // store reassignment: task -> userId
                  reassignment[task.taskId] = value;

                  debugPrint('Reassignment map: $reassignment');
                  debugPrint('Tasks length: ${tasks.length}');
                  debugPrint('Reassignment length: ${reassignment.length}');

                  onChanged();
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
