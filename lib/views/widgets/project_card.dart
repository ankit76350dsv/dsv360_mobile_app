import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project_model.dart';
import '../../core/services/auth_service.dart';
import '../attachment_screen/attachment_list_modal.dart';
// import '../../screens/tasks_screen.dart';
import '../task_screen/tasks_screen.dart';
import '../issue_screen/issues_screen.dart';
import 'generic_card.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yy');
    final dateRange =
        '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate)}';
    
    final isAdmin = AuthService().isAdmin;

    // Build chips list based on user role
    final chipsList = <CardChip>[
      CardChip(
        icon: Icons.attach_file,
        count: project.attachments.length.toString(),
        isActive: project.attachments.isNotEmpty,
        onTap: project.attachments.isNotEmpty
            ? () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AttachmentListModal(
                    attachments: project.attachments,
                  ),
                );
              }
            : null,
      ),
      CardChip(
        icon: Icons.task_alt,
        count: project.tasksCount.toString(),
        isActive: project.tasksCount > 0,
        onTap: project.tasksCount > 0
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TasksScreen(
                      projectId: project.id,
                      projectName: project.projectName,
                    ),
                  ),
                );
              }
            : null,
      ),
      // Show different chip based on role
      if (isAdmin)
        CardChip(
          icon: Icons.access_time,
          count: project.timeEntriesCount.toString(),
          isActive: project.timeEntriesCount > 0,
        )
      else
        CardChip(
          icon: Icons.assignment_outlined,
          count: project.issuesCount.toString(),
          isActive: project.issuesCount > 0,
          onTap: project.issuesCount > 0
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IssuesScreen(),
                    ),
                  );
                }
              : null,
        ),
    ];

    return GenericCard(
      id: project.id,
      name: project.projectName,
      status: project.status,
      subtitleIcon: 'business',
      subtitleText: project.client,
      dateRange: dateRange,
      chips: chipsList,
      onEdit: onEdit,
      onDelete: onDelete,
      onTap: onTap,
    );
  }
}
