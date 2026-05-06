import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/features/users/model/users.dart';
import 'package:dsv360/features/projects/viewmodel/project_viewmodel.dart';
import 'package:dsv360/features/task/repositories/task_repository.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_chip.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UserDetailsPage extends StatelessWidget {
  final UsersModel user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isAdmin = IsHaveAccess.instance.isAdmin;

    return DefaultTabController(
      length: isAdmin ? 4 : 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 35.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          elevation: 0,
          title: Text(
            "${user.firstName} ${user.lastName}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          // if needed can add the icon as well here
          // hook for info action
          // you can open a dialog or screen here
          actions: [],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _UserTabs(),
              Expanded(
                child: TabBarView(
                  children: [
                    _InfoTab(user: user),
                    if (isAdmin) _WorkInfoTab(user: user),
                    _ProjectsTab(user: user),
                    _TasksTab(user: user),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: customColors.tabbarBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: EdgeInsets.all(4.0),
        child: TabBar(
          indicator: BoxDecoration(
            color: customColors.tabbarIndicator, // white pill
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: customColors.textPrimary,
          unselectedLabelColor: customColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent, // removes bottom line
          tabs: [
            const Tab(text: "Info"),
            if (IsHaveAccess.instance.isAdmin) const Tab(text: "Work"),
            const Tab(text: "Projects"),
            const Tab(text: "Tasks"),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  final UsersModel user;

  const _InfoTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).custom;
    final verificationStatus = user.verificationStatus;
    final workStatus = user.workStatus;


    // final usersAsync = ref.watch(usersRepositoryProvider);

    // final List<DropdownMenuItem<String>> userOptions = usersAsync.when(
    //   data: (users) => users.map((u) {
    //     return DropdownMenuItem<String>(
    //       value: u.userId,
    //       child: Text("${u.firstName} ${u.lastName}"),
    //     );
    //   }).toList(),

    //   loading: () => [],
    //   error: (_, __) => [],
    // );

    final (verificationStatusText, verificationStatusIcon, verificationStatusColor) =
        switch (verificationStatus) {
          VerificationStatus.verified => (
            'Verified',
            Icons.verified,
            Colors.green,
          ),
          VerificationStatus.pending => (
            'Pending',
            Icons.hourglass_top,
            Colors.orange,
          ),
        };

    final (workStatusText, workStatusColor) = switch (workStatus) {
      WorkStatus.active => ('Active', Colors.green),
      WorkStatus.inactive => ('Inactive', const Color.fromARGB(255, 255, 0, 0)),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: "Personal Information"),
          _InfoTile(
            icon: Icons.person_outline_outlined,
            label: "Full Name",
            value: "${user.firstName} ${user.lastName}",
          ),
          _InfoTile(
            icon: Icons.badge,
            label: "User Id",
            value:
                "U${user.userId.length > 4 ? user.userId.substring(user.userId.length - 4) : user.userId}",
          ),
          _InfoTile(
            icon: Icons.verified_user,
            label: "Verification",
            child: CustomChip(
              label: verificationStatusText,
              color: verificationStatusColor,
              icon: verificationStatusIcon,
            ),
          ),
          _InfoTile(
            icon: Icons.work,
            label: "Role",
            child: CustomChip(
              color: customColors.primary!,
              label: user.role,
              icon: null,
            ),
          ),
          _InfoTile(
            icon: Icons.business_center,
            label: "Status",
            child: CustomChip(
              label: workStatusText,
              color: workStatusColor,
              icon: null,
            ),
          ),
          _InfoTile(
            icon: Icons.email,
            label: "Email Address",
            value: user.emailAddress,
          ),
          if (IsHaveAccess.instance.isAdmin)
            _InfoTile(
              icon: Icons.phone,
              label: "Phone Number",
              value: user.phone ?? 'N/A',
            ),
          if (IsHaveAccess.instance.isAdmin)
            _InfoTile(
              icon: Icons.person_2,
              label: "Reporting To",
              value: user.reporterName ?? 'N/A',
            ),

          // _InfoTile(
          //   icon: Icons.report_gmailerrorred,
          //   label: "Reporting To",
          //   value: user.reporterName,
          //   buttonWidget: CustomCardButton(
          //     onTap: () {
          //       showModalBottomSheet(
          //         context: context,
          //         isScrollControlled: true,
          //         shape: const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.vertical(
          //             top: Radius.circular(16),
          //           ),
          //         ),
          //         builder: (_) => ReportingManagerBottomSheet(
          //           usersAsync: usersAsync,
          //           userOptions: userOptions,
          //         ),
          //       );
          //     },
          //     icon: Icons.edit,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _WorkInfoTab extends ConsumerWidget {
  final UsersModel user;

  const _WorkInfoTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: "Work Information"),
          _InfoTile(
            icon: Icons.badge,
            label: "Employee Id",
            value: user.empId ?? 'N/A',
          ),
          _InfoTile(
            icon: Icons.location_city,
            label: "Office Location",
            value: user.location ?? 'N/A',
          ),
          _InfoTile(
            icon: Icons.lock_clock,
            label: "Shift Start Time",
            value: user.shiftStartTime ?? 'N/A',
          ),
          _InfoTile(
            icon: Icons.lock_clock_rounded,
            label: "Shift End Time",
            value: user.shiftEndTime ?? 'N/A',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: customColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value; // for normal text
  final Widget? child; // for chips, buttons, etc

  const _InfoTile({
    required this.icon,
    required this.label,
    this.value,
    this.child,
  }) : assert(
         value != null || child != null,
         'Either value or child must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: customColors.primary!.withOpacity(0.2),
                  child: Icon(icon, size: 20, color: customColors.primary),
                ),
                const SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: customColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (value == null) const SizedBox(height: 6),

                    // 👇 Either text OR custom widget
                    if (value != null)
                      Text(value!, style: textTheme.titleMedium)
                    else
                      child!,
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// reporting manager selection provider
class ReportingManagerSelection {
  final String? id;
  final String? name;

  const ReportingManagerSelection({this.id, this.name});
}

final reportingManagerProvider =
    NotifierProvider<ReportingManagerNotifier, ReportingManagerSelection?>(
      ReportingManagerNotifier.new,
    );

class ReportingManagerNotifier extends Notifier<ReportingManagerSelection?> {
  @override
  ReportingManagerSelection? build() => null;

  void setManager({required String id, required String name}) {
    state = ReportingManagerSelection(id: id, name: name);
  }

  void clear() {
    state = null;
  }
}

class ReportingManagerBottomSheet extends ConsumerWidget {
  final AsyncValue<List<UsersModel>> usersAsync;
  final List<DropdownMenuItem<String>> userOptions;

  const ReportingManagerBottomSheet({
    super.key,
    required this.usersAsync,
    required this.userOptions,
  });

  final String bottomTwoButtonsLoadingKey = 'reporting_manager_key';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedManager = ref.watch(reportingManagerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              'Select Reporting Manager',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            CustomDropDownField(
              options: userOptions,
              hintText: "Select Reporting Manager",
              labelText: "Reporting Manager",
              prefixIcon: Icons.report_gmailerrorred,
              onChanged: (value) {
                if (value == null) return;

                usersAsync.whenData((users) {
                  final selectedUser = users.firstWhere(
                    (u) => u.userId == value,
                  );

                  ref
                      .read(reportingManagerProvider.notifier)
                      .setManager(
                        id: selectedUser.userId,
                        name:
                            '${selectedUser.firstName} ${selectedUser.lastName}'
                                .trim(),
                      );
                });
              },
            ),

            const SizedBox(height: 12),

            if (selectedManager != null)
              Text(
                'Selected: ${selectedManager.name}',
                style: Theme.of(context).textTheme.bodySmall,
              ),

            const SizedBox(height: 10),
            // bottom buttons
            BottomTwoButtons(
              loadingKey: bottomTwoButtonsLoadingKey,
              button1Text: 'Cancel',
              button2Text: 'save changes',
              button1Function: () => Navigator.pop(context),
              button2Function: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsTab extends ConsumerWidget {
  final UsersModel user;
  const _ProjectsTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);
    final connectivityStatus = ref.watch(checkConnectivityProvider);

    return connectivityStatus.when(
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

        return projectsAsync.when(
          loading: () =>
              const GlobalLoader(message: 'Loading projects info...'),
          error: (error, stack) => GlobalError(
            message: 'Failed to load data. Please try again.',
            onRetry: () => ref.refresh(projectListProvider),
          ),
          data: (projects) {
            final userId = user.userId;

            final assignedProjects = projects
                .where((p) => p.assignedToId == userId)
                .toList();

            if (assignedProjects.isEmpty) {
              return const Center(child: Text("No projects assigned"));
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(projectListProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: assignedProjects.length,
                itemBuilder: (context, index) {
                  return _ProjectCard(project: projects[index]);
                },
              ),
            );
          },
        );
      },
      error: (error, stack) => GlobalError(
        message: 'Something went wrong. Please check your connection.',
        onRetry: () => ref.invalidate(checkConnectivityProvider),
      ),
      loading: () => const GlobalLoader(message: 'Checking connection...'),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const _ProjectCard({required this.project});

  String _formatDateRange(DateTime date) {
    final startDate = DateFormat('MMM dd, yyyy').format(date);
    final now = DateFormat('MMM dd, yyyy').format(DateTime.now());
    return '$startDate - $now';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).custom;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
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
                    // project ID
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "P${project.id.substring(project.id.length - 4)}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    CustomChip(
                      label: project.status,
                      color: colorScheme.primary!,
                      icon: null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),

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
                            project.projectName,
                            style: TextStyle(
                              color: colorScheme.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2.0),
                          InfoRow(
                            icon: Icons.description_outlined,
                            text: project.description ?? '',
                          ),
                          InfoRow(
                            icon: Icons.date_range,
                            text: _formatDateRange(project.startDate),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TasksTab extends ConsumerWidget {
  final UsersModel user;
  const _TasksTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksListRepositoryProvider(user.userId));
    final connectivityStatus = ref.watch(checkConnectivityProvider);

    return connectivityStatus.when(
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

        return tasksAsync.when(
          loading: () => const GlobalLoader(message: 'Loading tasks info...'),
          error: (error, stack) => GlobalError(
            message: 'Failed to load tasks data: Try Again',
            onRetry: () =>
                ref.refresh(tasksListRepositoryProvider(user.userId)),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return const Center(child: Text("No tasks assigned"));
            }

            final userId = user.userId;
            final assignedTasks = tasks
                .where((t) => t.assignedToId == userId)
                .toList();

            if (assignedTasks.isEmpty) {
              return const Center(child: Text("No tasks assigned"));
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(tasksListRepositoryProvider(user.userId));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: assignedTasks.length,
                itemBuilder: (context, index) {
                  return _TaskCard(task: assignedTasks[index]);
                },
              ),
            );
          },
        );
      },
      error: (error, stack) => GlobalError(
        message: 'Something went wrong. Please check your connection.',
        onRetry: () => ref.invalidate(checkConnectivityProvider),
      ),
      loading: () => const GlobalLoader(message: 'Checking connection...'),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    // final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // task ID
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: customColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "T${task.taskId.substring(task.taskId.length - 4)}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    CustomChip(
                      label: task.status,
                      color: customColors.primary!,
                      icon: null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),

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
                            task.taskName,
                            style: TextStyle(
                              color: customColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2.0),
                          InfoRow(
                            icon: Icons.description_outlined,
                            text: task.description,
                          ),
                          InfoRow(
                            icon: Icons.date_range,
                            text:
                                "${_fmt(task.startDate)} → ${_fmt(task.endDate)}",
                          ),
                          InfoRow(
                            icon: Icons.person,
                            text: task.assignedTo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime? date) {
    if (date == null) return '—';
    return "${date.day}/${date.month}/${date.year}";
  }
}
