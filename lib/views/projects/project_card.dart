import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project_model.dart';
import 'attachment_list_modal.dart';
// import '../tasks_screen.dart';
import '../widgets/generic_card.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yy');
    final dateRange =
        '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate)}';

    return GenericCard(
      id: project.id,
      name: project.projectName,
      status: project.status,
      subtitleIcon: 'business',
      subtitleText: project.client,
      dateRange: dateRange,
      chips: [
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
                      // builder: (context) => TasksScreen(
                      //   projectId: project.id,
                      //   projectName: project.projectName,
                      // ),
                      builder: (context) => Text(
                       "Hello"
                      ),
                    ),
                  );
                }
              : null,
        ),
        CardChip(
          icon: Icons.access_time,
          count: project.timeEntriesCount.toString(),
          isActive: project.timeEntriesCount > 0,
        ),
      ],
      onEdit: onEdit,
      onDelete: onDelete,
      onTap: onTap,
    );
  }
}
