import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SprintProjectSelector extends StatelessWidget {
  final AsyncValue<List<dynamic>> projectsAsync;
  final String? selectedProjectName;
  final String? selectedSprintId;
  final String? selectedSprintStatus;
  final String? selectedSprintName;
  final bool canManageSprints;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final VoidCallback onProjectTap;
  final Future<void> Function() onCompleteSprintTap;

  const SprintProjectSelector({
    super.key,
    required this.projectsAsync,
    required this.selectedProjectName,
    required this.selectedSprintId,
    required this.selectedSprintStatus,
    required this.selectedSprintName,
    required this.canManageSprints,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    required this.onProjectTap,
    required this.onCompleteSprintTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            'PROJECT',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: projectsAsync.when(
              loading: () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: greyBorder, width: 1),
                ),
                child: Text(
                  'Loading...',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ),
              error: (error, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  'Error loading projects',
                  style: TextStyle(color: textSecondary),
                ),
              ),
              data: (_) => SizedBox(
                height: 35,
                child: GestureDetector(
                  onTap: onProjectTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: greyBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedProjectName ?? 'Select Project',
                            style: TextStyle(
                              color: selectedProjectName == null
                                  ? textSecondary
                                  : textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: textSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (canManageSprints && selectedSprintId != null)
            GestureDetector(
              onTap: selectedSprintStatus == 'ACTIVE'
                  ? () async {
                      final isConfirmed = await showWarningDialogueBox(
                        context: context,
                        title: "Complete Sprint",
                        subtitle:
                            "Are you sure you want to mark \nSprint : $selectedSprintName\n as Complete?",
                        primaryText: "Complete",
                      );
                      if (isConfirmed == true) {
                        await onCompleteSprintTap();
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedSprintStatus == 'ACTIVE'
                        ? primary
                        : primary.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  selectedSprintStatus == 'ACTIVE'
                      ? 'Complete Sprint'
                      : 'Completed',
                  style: TextStyle(
                    color: selectedSprintStatus == 'ACTIVE'
                        ? primary
                        : primary.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
