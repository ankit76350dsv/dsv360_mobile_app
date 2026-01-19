import 'package:dsv360/models/project_model.dart';
import 'package:dsv360/models/task.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/providers/project_provider.dart';
import 'package:dsv360/repositories/task_repository.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
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
                    _TasksTab(),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withOpacity(0.7), // light grey background
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

class _InfoTab extends StatelessWidget {
  final UsersModel user;

  late String verificationStatusText;
  late IconData verificationStatusIcon;
  late Color verificationStatusColor;

  late String workStatusText;
  late Color workStatusColor;

  _InfoTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final verificationStatus = user.verificationStatus;
    final workStatus = user.workStatus;

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
        workStatusColor =  Color.fromARGB(255, 255, 0, 0);
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
              crossAxisCount: 2, // ✅ 2 columns
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 2.1, // adjust for tile height
            ),
            children: [
              _InfoTile(
                icon: Icons.badge, 
                label: "User Id", 
                value: user.userId,
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
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // ✅ 2 columns
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 2.1, // adjust for tile height
            ),
            children: [
              _InfoTile(
                icon: Icons.work,
                label: "Role",
                child: CustomChip(
                  color: colors.primary,
                  label: user.role,
                  icon: null
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
            ],
          ),
          _InfoTile(
            icon: Icons.email,
            label: "Email Address",
            value: user.emailAddress,
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
  final String? value;   // for normal text
  final Widget? child;   // for chips, buttons, etc

  const _InfoTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.child,
  }) : assert(value != null || child != null,
        'Either value or child must be provided');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: colors.primary.withOpacity(0.4),
              child: Icon(icon, size: 28, color: colors.primary),
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colors.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (value == null)
                  const SizedBox(height: 6),

                // 👇 Either text OR custom widget
                if (value != null)
                  Text(value!, style: textTheme.titleMedium)
                else
                  child!,
              ],
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
    final projectsAsync = ref.watch(projectListProvider);

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
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProjectCard(project: projects[index]),
            );
          },
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;

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
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
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
                    project.projectName,
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
  const _TasksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskRepositoryProvider);

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
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TaskCard(task: tasks[index]),
            );
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
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
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
                Chip(
                  label: Text(task.status),
                  backgroundColor: colors.primaryContainer,
                  labelStyle: TextStyle(color: colors.onPrimaryContainer),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: colors.primaryContainer, width: 1),
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

  String _fmt(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }
}
