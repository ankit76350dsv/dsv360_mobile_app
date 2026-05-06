import 'package:dsv360/features/sprints/view/pages/backlog_page.dart';
import 'package:flutter/material.dart';

class SprintBacklogTab extends StatelessWidget {
  final String? selectedProjectId;
  final String? selectedProjectName;
  final String? widgetProjectId;
  final String? widgetProjectName;
  final Color textSecondary;

  const SprintBacklogTab({
    super.key,
    required this.selectedProjectId,
    required this.selectedProjectName,
    required this.widgetProjectId,
    required this.widgetProjectName,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final projectId = selectedProjectId ?? widgetProjectId;
    if (projectId == null || projectId.isEmpty) {
      return Center(
        child: Text(
          'Select a project to view backlog',
          style: TextStyle(color: textSecondary, fontSize: 14),
        ),
      );
    }
    return BacklogPage(
      projectId: projectId,
      projectName: selectedProjectName ?? widgetProjectName,
    );
  }
}
