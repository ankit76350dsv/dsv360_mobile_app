import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/users/repositories/delete_user_repository.dart';

import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/features/users/model/users.dart';

import 'package:dsv360/features/users/repositories/pending_tasks_repository.dart';

import 'package:dsv360/features/users/repositories/users_repository.dart';
import 'package:dsv360/features/dashboard/view/widgets/AppDrawer.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';

import 'package:dsv360/features/users/view/pages/add_edit_user_page.dart';
import 'package:dsv360/features/users/view/pages/user_details_page.dart';
import 'package:dsv360/core/widgets/app_snackbar.dart';
import 'package:dsv360/core/widgets/custom_card_button.dart';
import 'package:dsv360/core/widgets/custom_chip.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/custom_input_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  bool _isRefreshingData = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersRepositoryProvider);
    final query = ref.watch(usersSearchQueryProvider);
    final connectivityStatus = ref.watch(checkConnectivityProvider);
    final customColors = Theme.of(context).custom;

    final userRole = AuthManager.instance.currentUser?.role?.name
        .toLowerCase(); //get user role here

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              if (_isRefreshingData) return;
              setState(() => _isRefreshingData = true);
              try {
                final _ = await ref.refresh(usersRepositoryProvider.future);
                if (mounted) {
                  showSuccessSnackBar(context, 'Users refreshed successfully');
                }
              } catch (e) {
                debugPrint('Refresh error: $e');
                if (mounted) {
                  showErrorSnackBar(context, 'Refresh failed. Please try again.');
                }
              } finally {
                if (mounted) {
                  setState(() => _isRefreshingData = false);
                }
              }
            },
          ),
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, //add fab logic here
      floatingActionButton: (userRole == 'admin' || userRole == 'super admin')
          ? connectivityStatus.when(
              data: (results) {
                if (results.contains(ConnectivityResult.none)) return null;
                if (usersAsync.hasError) return null;
                return FloatingActionButton(
                  backgroundColor: customColors.primary,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditUserPage(user: null),
                      ),
                    );
                  },
                  child: Icon(Icons.person_add, size: 22),
                );
              },
              loading: () => null,
              error: (_, __) => null,
            )
          : null,

      body: SafeArea(
        child: connectivityStatus.when(
          data: (results) {
            if (results.contains(ConnectivityResult.none)) {
              return GlobalError(
                message: 'Please check your internet connection.',
                isNetworkError: true,
                onRetry: () {
                  ref.invalidate(checkConnectivityProvider);
                },
              );
            }

            // When connected, show accounts data
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(usersRepositoryProvider);
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: usersAsync.when(
                        loading: () => const GlobalLoader(
                          message: 'Loading users info...',
                        ),
                        error: (error, stack) => GlobalError(
                          message: 'Failed to load users data: Try Again',
                          onRetry: () => ref.refresh(usersRepositoryProvider),
                        ),
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
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color:
                                                (customColors.primary ??
                                                        Colors.blue)
                                                    .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.person_search_outlined,
                                            size: 48,
                                            color:
                                                customColors.primary ??
                                                Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No Users Found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: customColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32.0,
                                          ),
                                          child: Text(
                                            query.isEmpty
                                                ? 'There are currently no users to display.'
                                                : 'No users match your search query "$query".',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: customColors.textSecondary,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
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
            );
          },
          error: (error, stack) => GlobalError(
            message: 'Failed to check connectivity: Try Again',
            onRetry: () => ref.invalidate(checkConnectivityProvider),
          ),
          loading: () => const GlobalLoader(message: 'Checking connection...'),
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
    final customColors = theme.custom;
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
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: customColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "U${widget.user.userId.substring(widget.user.userId.length - 4)}",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const Spacer(),
                      CustomChip(
                        label: widget.user.role,
                        color: customColors.primary!,
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
                  Column(
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
                ],
              ),
            ),

            // Divider
            if (IsHaveAccess.instance.isAdmin)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withOpacity(0.2),
              ),

            if (IsHaveAccess.instance.isAdmin)
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
                                          ? 'time_entry_management_application_function/employee/DISABLED/${widget.user.userId}'
                                          // to make it inactive (now value is false, previous was true)
                                          : 'time_entry_management_application_function/employee/ACTIVE/${widget.user.userId}';
                                      await ApiClient.instance.post(path);

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
                                    ? customColors.primary
                                    : customColors.textWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            widget.user.verificationStatus !=
                                    VerificationStatus.verified
                                ? CustomCardButton(
                                    icon: Icons.account_circle,
                                    onTap: () async {
                                      try {
                                        await ApiClient.instance.post(
                                          'time_entry_management_application_function/reInviteEmployees',
                                          data: {
                                            'email_id': widget.user.emailAddress
                                                .toString(),
                                            'first_name': widget.user.firstName
                                                .toString(),
                                            'last_name': widget.user.lastName
                                                .toString(),
                                            'role_id': widget.user.roleId
                                                .toString(),
                                            'user_id': widget.user.userId
                                                .toString(),
                                          },
                                        );

                                        AppSnackBar.show(
                                          context,
                                          message:
                                              'Re-invitation sent successfully',
                                        );
                                      } catch (e) {
                                        debugPrint(
                                          '❌ Failed to sent invitation: $e',
                                        );

                                        AppSnackBar.show(
                                          context,
                                          message:
                                              'Failed to sent re-invitation.',
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
                              color: customColors.error,
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
      isScrollControlled: true,
      builder: (_) {
        return _DeleteUserBottomSheet(user: user, usersList: usersList);
      },
    );
  }

  Widget _userInfoRow(IconData icon, String text) {
    final customColors = Theme.of(context).custom;

    return Row(
      children: [
        Icon(icon, size: 18, color: customColors.textSecondary),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: customColors.textSecondary)),
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
    final _deleteUserRepository = DeleteUserRepository();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
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
                          hasPendingTasks
                              ? 'Task Assignment'
                              : 'No Tasks Pending?',
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
                            final reassignmentPayload =
                                _buildReassignmentPayload(
                                  tasks,
                                  reassignment,
                                  widget.usersList,
                                );

                            debugPrint(
                              'Reassignment payload: $reassignmentPayload',
                            );

                            try {
                              // ALWAYS hit delete API
                              await _deleteUserRepository.deleteUser(
                                userId: widget.user.userId,
                                reassignmentPayload: reassignmentPayload,
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

                              Navigator.pop(context, true);

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
