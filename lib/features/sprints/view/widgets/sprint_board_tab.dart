import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/sprints/view/widgets/board_view.dart';
import 'package:dsv360/features/sprints/view/widgets/sprint_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SprintBoardTab extends StatelessWidget {
  final AsyncValue<List<SprintStory>> hierarchyAsync;
  final AsyncValue<dynamic> sprintsAsync;
  final String? selectedProjectId;
  final String? selectedProjectName;
  final String? selectedSprintId;
  final String? selectedSprintName;
  final String? widgetProjectId;
  final String? widgetProjectName;
  final bool canManageSprints;
  final String? activeUserId;
  final bool isDark;
  final CustomColors customColors;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final void Function(SprintStory, String) onMove;
  final int Function(List<SprintStory>) totalPoints;
  final int Function(List<SprintStory>) completedPoints;
  final int Function(List<SprintStory>) totalStories;
  final int Function(List<SprintStory>) completedStories;
  final double Function(List<SprintStory>) progress;
  final VoidCallback onRetry;

  const SprintBoardTab({
    super.key,
    required this.hierarchyAsync,
    required this.sprintsAsync,
    required this.selectedProjectId,
    required this.selectedProjectName,
    required this.selectedSprintId,
    required this.selectedSprintName,
    required this.widgetProjectId,
    required this.widgetProjectName,
    required this.canManageSprints,
    required this.activeUserId,
    required this.isDark,
    required this.customColors,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    required this.onMove,
    required this.totalPoints,
    required this.completedPoints,
    required this.totalStories,
    required this.completedStories,
    required this.progress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final projectId = selectedProjectId ?? widgetProjectId;
    if (projectId == null || projectId.isEmpty) {
      return Center(
        child: Text(
          'Select a project to view board',
          style: TextStyle(color: textSecondary, fontSize: 14),
        ),
      );
    }

    return hierarchyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: customColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'Failed to load board',
                style: TextStyle(color: textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                e.toString().replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text('Retry', style: TextStyle(color: Colors.blue.shade400)),
              ),
            ],
          ),
        ),
      ),
      data: (stories) {
        final visibleStories = canManageSprints
            ? stories
            : stories.where((s) => s.assigneeId == activeUserId).toList();

        String? sprintEndDate;
        sprintsAsync.whenData((sprints) {
          try {
            final selectedSprint = sprints.firstWhere(
              (s) => s.rowId == selectedSprintId,
            );
            sprintEndDate = selectedSprint.endDate;
          } catch (_) {}
        });

        return BoardView(
          stories: visibleStories,
          onMove: onMove,
          isDark: isDark,
          customColors: customColors,
          cardBg: cardBg,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          greyBorder: greyBorder,
          primary: primary,
          progress: progress(stories),
          completedPoints: completedPoints(stories),
          totalPoints: totalPoints(stories),
          completedStories: completedStories(stories),
          totalStories: totalStories(stories),
          projectId: projectId,
          projectName: selectedProjectName ?? widgetProjectName,
          sprintId: selectedSprintId,
          sprintName: selectedSprintName,
          sprintEndDate: sprintEndDate,
        );
      },
    );
  }
}
