import 'package:dsv360/models/active_user.dart';
import 'package:dsv360/models/project.dart';
import 'package:dsv360/models/task.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/project_repository.dart';
import 'package:dsv360/repositories/task_repository.dart';
import 'package:dsv360/repositories/users_repository.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UserDetailsPage extends StatelessWidget {
  final UsersModel user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "${user.firstName} ${user.lastName}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: colors.surface,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _UserTabs(),
              Expanded(
                child: TabBarView(
                  children: [
                    _InfoTab(user: user),
                    _ProjectsTab(),
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
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withOpacity(
            0.7,
          ), // light grey background
          borderRadius: BorderRadius.circular(14),
        ),
        padding: EdgeInsets.all(4.0),
        child: TabBar(
          indicator: BoxDecoration(
            color: colors.secondary, // white pill
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
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent, // removes bottom line
          tabs: const [
            Tab(text: "Info"),
            Tab(text: "Projects"),
            Tab(text: "Tasks"),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  final UsersModel user;

  late String verificationStatusText;
  late IconData verificationStatusIcon;
  late Color verificationStatusColor;

  late String workStatusText;
  late Color workStatusColor;

  _InfoTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final verificationStatus = user.verificationStatus;
    final workStatus = user.workStatus;
    final usersAsync = ref.watch(usersRepositoryProvider);

    final List<DropdownMenuItem<String>> userOptions = usersAsync.when(
      data: (users) => users.map((u) {
        return DropdownMenuItem<String>(
          value: u.userId,
          child: Text("${u.firstName} ${u.lastName}"),
        );
      }).toList(),

      loading: () => [],
      error: (_, __) => [],
    );

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

    switch (workStatus) {
      case WorkStatus.active:
        workStatusText = "Active";
        workStatusColor = Colors.green;
        break;
      case WorkStatus.inactive:
        workStatusText = "Inactive";
        workStatusColor = Color.fromARGB(255, 255, 0, 0);
        break;
    }

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
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 0,
              childAspectRatio: 2.1, // adjust for tile height
            ),
            children: [
              _InfoTile(
                icon: Icons.badge,
                label: "User Id",
                value: "U${user.userId.substring(user.userId.length - 4)}",
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
            ],
          ),
          _InfoTile(
            icon: Icons.work,
            label: "Role",
            child: CustomChip(
              color: colors.primary,
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
          _InfoTile(
            icon: Icons.report_gmailerrorred,
            label: "Reporting To",
            value: user.reporterName,
            buttonWidget: CustomCardButton(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (_) => ReportingManagerBottomSheet(
                    usersAsync: usersAsync,
                    userOptions: userOptions,
                  ),
                );
              },
              icon: Icons.edit,
            ),
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
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colors.primary,
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
  final Widget? buttonWidget; // button widget

  const _InfoTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.child,
    this.buttonWidget,
  }) : assert(
         value != null || child != null,
         'Either value or child must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.primary.withOpacity(0.4),
                  child: Icon(icon, size: 20, color: colors.primary),
                ),
                const SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.tertiary,
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
            if (buttonWidget != null) buttonWidget!,
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
                        id: selectedUser.userId!,
                        name:
                            '${selectedUser.firstName ?? ''} ${selectedUser.lastName ?? ''}'
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsRepositoryProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(child: _EmptyBox(text: "No projects assigned"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            return _ProjectCard(project: projects[index]);
          },
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  String _formatDateRange() {
    final startDate = DateFormat('MMM dd, yyyy').format(project.startDate!);
    final now = DateFormat('MMM dd, yyyy').format(DateTime.now());
    return '$startDate - $now';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (project.startDate != null)
                    Text(
                      _formatDateRange(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

            // Status chip
            Chip(
              label: Text(project.status),
              backgroundColor: colors.primaryContainer,
              labelStyle: TextStyle(color: colors.onPrimaryContainer),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(color: colors.primaryContainer, width: 1),
            ),
          ],
        ),
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

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: _EmptyBox(text: "No tasks assigned"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return _TaskCard(task: tasks[index]);
          },
        );
      },
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;

  const _EmptyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title
            Text(task.taskName, style: textTheme.titleMedium),

            const SizedBox(height: 6),

            // Project
            Text(
              task.projectName,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              task.description,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 12),

            // Bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status chip
                CustomChip(
                  label: task.status, 
                  color: colors.primaryContainer, 
                  icon: null,
                ),

                // Date range
                Text(
                  "${_fmt(task.startDate)} → ${_fmt(task.endDate)}",
                  style: textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Assigned to
            Row(
              children: [
                Icon(Icons.person, size: 16, color: colors.primary),
                const SizedBox(width: 6),
                Text(task.assignedTo, style: textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime? date) {
    if (date == null) return '—';
    return "${date.day}/${date.month}/${date.year}";
  }
}
