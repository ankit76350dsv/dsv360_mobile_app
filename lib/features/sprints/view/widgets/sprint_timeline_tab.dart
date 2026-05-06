import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/sprints/view/widgets/timeline_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SprintTimelineTab extends StatelessWidget {
  final AsyncValue<dynamic> rawAsync;
  final AsyncValue<dynamic> sprintsAsync;
  final String? selectedProjectId;
  final String? selectedSprintId;
  final String? selectedSprintName;
  final String? widgetProjectId;
  final bool isDark;
  final CustomColors customColors;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final bool canManageSprints;
  final String? currentUserId;
  final VoidCallback onRetry;

  const SprintTimelineTab({
    super.key,
    required this.rawAsync,
    required this.sprintsAsync,
    required this.selectedProjectId,
    required this.selectedSprintId,
    required this.selectedSprintName,
    required this.widgetProjectId,
    required this.isDark,
    required this.customColors,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    required this.canManageSprints,
    required this.currentUserId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final projectId = selectedProjectId ?? widgetProjectId;
    if (projectId == null || projectId.isEmpty) {
      return Center(
        child: Text(
          'Select a project to view timeline',
          style: TextStyle(color: textSecondary, fontSize: 14),
        ),
      );
    }

    return rawAsync.when(
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
                'Failed to load timeline',
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
      data: (hierarchy) {
        String? sprintStart;
        String? sprintEnd;
        sprintsAsync.whenData((sprints) {
          try {
            final s = sprints.firstWhere((s) => s.rowId == selectedSprintId);
            sprintStart = s.startDate;
            sprintEnd = s.endDate;
          } catch (_) {}
        });
        return TimelineView(
          hierarchy: hierarchy,
          sprintId: selectedSprintId,
          isDark: isDark,
          cardBg: cardBg,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          greyBorder: greyBorder,
          primary: primary,
          sprintStartDate: sprintStart,
          sprintEndDate: sprintEnd,
          sprintName: selectedSprintName,
          canManageSprints: canManageSprints,
          currentUserId: currentUserId,
        );
      },
    );
  }
}
