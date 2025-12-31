import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/project.dart';
import 'package:dsv360/models/task.dart';
import 'package:dsv360/models/users.dart';
import 'package:flutter/material.dart';
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
              _TopHeader(user: user),
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

class _TopHeader extends StatelessWidget {
  final UsersModel user;

  const _TopHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.primary],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.cloud, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final UsersModel user;

  const _InfoTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: "Personal Information"),
          _InfoTile(icon: Icons.person, label: "Full Name", value: user.name),
          _InfoTile(icon: Icons.badge, label: "User Id", value: user.userId),
          _InfoTile(
            icon: Icons.email,
            label: "Email Address",
            value: user.emailAddress,
          ),
          _InfoTile(icon: Icons.work, label: "Role", value: user.role),
          _WorkStatusRow(
            user: user,
            label: "Status",
            icon: Icons.business_center,
          ),
          _VerificationStatusRow(
            user: user,
            label: "Verification",
            icon: Icons.verified_user,
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

class _ProjectsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Project> projects = [
      Project(
        id: "1",
        name: "Employee Management",
        status: "open",
        tasksCount: 12,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Project(
        id: "2",
        name: "Payroll Integration",
        status: "active",
        tasksCount: 7,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Project(
        id: "3",
        name: "Mobile App Development",
        status: "on_hold",
        tasksCount: 20,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    if (projects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [_EmptyBox(text: "No projects assigned")],
        ),
      );
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
      color: colors.secondaryContainer,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab();

  @override
  Widget build(BuildContext context) {
    final List<Task> tasks = [
      Task.fromJson({
        "Status": "Open",
        "Description": "jhv",
        "Project_Name": "testing",
        "Task_Name": "Abhay Singh Patel",
        "Start_Date": "2025-11-03",
        "End_Date": "2025-11-30",
        "Assign_To": "adsadas Patel",
      }),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: tasks.map((task) {
          return _TaskCard(task: task);
        }).toList(),
      ),
    );
  }
}

class _WorkStatusRow extends StatelessWidget {
  final UsersModel user;
  final String label;
  final IconData icon;

  const _WorkStatusRow({
    required this.user,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

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
              Chip(
                label: Text(
                  user.workStatus.name.toLowerCase(),
                  style: TextStyle(color: colors.onPrimaryContainer),
                ),
                visualDensity: VisualDensity.compact,
                backgroundColor: colors.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerificationStatusRow extends StatelessWidget {
  final UsersModel user;
  final String label;
  final IconData icon;

  const _VerificationStatusRow({
    required this.user,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    late final String statusText;
    late final Color bgColor;
    late final Color fgColor;

    switch (user.verificationStatus) {
      case VerificationStatus.verified:
        statusText = "Verified";
        bgColor = colors.secondaryContainer;
        fgColor = colors.onSecondaryContainer;
        break;
      case VerificationStatus.pending:
        statusText = "Pending";
        bgColor = colors.tertiaryContainer;
        fgColor = colors.onTertiaryContainer;
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 28, color: colors.primary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(statusText, style: TextStyle(color: fgColor)),
              backgroundColor: bgColor,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ],
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
      color: colors.secondaryContainer,
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
