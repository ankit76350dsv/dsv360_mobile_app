import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/project_model.dart';
import '../../../../core/constants/auth_manager.dart';
import '../../../../views/attachments/attachment_list_modal.dart';
// import '../../screens/tasks_screen.dart';
import '../../../../views/task/tasks_screen.dart';
import '../../../issues/view/pages/issues_screen.dart';
import '../../../time_entry/view/pages/time_entries_screen.dart';
import '../../../../views/widgets/generic_card.dart';

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
    
    final user = AuthManager.instance.currentUser;
    final isAdmin = user?.role?.name == 'Admin';

    // Build chips list based on user role
    final chipsList = <CardChip>[
      CardChip(
        icon: Icons.attach_file,
        count: project.attachments.length.toString(),
        isActive: project.attachments.isNotEmpty,
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AttachmentListModal(
              attachments: project.attachments,
            ),
          );
        },
      ),
      CardChip(
        icon: Icons.task_alt,
        count: project.tasksCount.toString(),
        isActive: project.tasksCount > 0,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TasksScreen(
                projectId: project.id,
                projectName: project.projectName,
              ),
            ),
          );
        },
      ),
      // Show different chip based on role
      if (isAdmin)
        CardChip(
          icon: Icons.access_time,
          count: project.timeEntriesCount.toString(),
          isActive: project.timeEntriesCount > 0,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TimeEntriesScreen(
                  taskId: '',
                  projectId: project.id,
                  taskName: project.projectName,
                  projectName: project.projectName,
                  timeEntries: [],
                ),
              ),
            );
          },
        )
      else
        CardChip(
          icon: Icons.assignment_outlined,
          count: project.issuesCount.toString(),
          isActive: project.issuesCount > 0,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const IssuesScreen(),
              ),
            );
          },
        ),
    ];

    return GenericCard(
      id: project.id.length > 4 
          ? 'P${project.id.substring(project.id.length - 4)}' 
          : 'P${project.id}',
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
