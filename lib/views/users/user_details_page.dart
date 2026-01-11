import 'package:dsv360/models/project.dart';
import 'package:dsv360/models/task.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/project_repository.dart';
import 'package:dsv360/repositories/task_repository.dart';
import 'package:dsv360/views/widgets/RoleChip.dart';
import 'package:dsv360/views/widgets/TopHeaderBar.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
import 'package:dsv360/views/widgets/WorkStatusChip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UserDetailsPage extends StatelessWidget {
  final UsersModel user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              TopHeaderBar(heading: "${user.firstName} ${user.lastName}"),
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
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TabBar(
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.textTheme.bodyMedium?.color,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: "Info"),
          Tab(text: "Projects"),
          Tab(text: "Tasks"),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final UsersModel user;

  late String verificationStatusText;
  late IconData verificationStatusIcon;
  late Color verificationStatusColor;

  _InfoTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final verificationStatus = user.verificationStatus;

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: "Personal Information"),
          _InfoTile(
            icon: Icons.person,
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
              childAspectRatio: 2.2, // adjust for tile height
            ),
            children: [
              _InfoTile(icon: Icons.badge, label: "User Id", value: "U12345"),
              _InfoTileCustom(
                icon: Icons.verified_user,
                label: "Verification",
                widget: CustomChip(
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
              childAspectRatio: 2.2, // adjust for tile height
            ),
            children: [
              _InfoTileCustom(
                icon: Icons.work,
                label: "Role",
                widget: RoleChip(text: user.role),
              ),
              _InfoTileCustom(
                icon: Icons.business_center,
                label: "Status",
                widget: WorkStatusChip(status: user.workStatus),
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
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTileCustom extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget widget;

  const _InfoTileCustom({
    required this.icon,
    required this.label,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              widget,
            ],
          ),
        ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
