import 'package:dsv360/features/sprints/model/sprints_model.dart';
import 'package:dsv360/features/sprints/model/timer_info_model.dart';
import 'package:dsv360/features/sprints/view/pages/create_epic_page.dart';
import 'package:dsv360/features/sprints/view/pages/create_release_page.dart';
import 'package:dsv360/features/sprints/view/pages/create_sprint_page.dart';
import 'package:dsv360/features/sprints/view/pages/create_story_page.dart';
import 'package:dsv360/features/sprints/view/pages/stop_timer_page.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/sprints/viewmodel/timer_viewmodel.dart';
import 'package:dsv360/features/task/viewmodel/task_viewmodel.dart';

final _runningTimerProvider = StreamProvider.autoDispose
    .family<TimerInfoModel?, String>((ref, userId) {
      return ref
          .read(timerRepositoryProvider)
          .watchTimerInfo(
            userId: userId,
            interval: const Duration(seconds: 10),
          );
    });

class SprintCycleBar extends StatelessWidget {
  final AsyncValue<List<SprintModel>> sprintsAsync;
  final String? selectedProjectId;
  final String? selectedProjectName;
  final String? selectedSprintId;
  final String? selectedSprintName;
  final String? selectedSprintStatus;
  final bool canManageSprints;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final VoidCallback onSprintTap;
  final String? widgetProjectId;
  final String? widgetProjectName;

  const SprintCycleBar({
    super.key,
    required this.sprintsAsync,
    required this.selectedProjectId,
    required this.selectedProjectName,
    required this.selectedSprintId,
    required this.selectedSprintName,
    required this.selectedSprintStatus,
    required this.canManageSprints,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    required this.onSprintTap,
    this.widgetProjectId,
    this.widgetProjectName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final userId = ref.watch(currentUserIdProvider);
        final runningTimerAsync = userId.isEmpty
            ? const AsyncValue<TimerInfoModel?>.data(null)
            : ref.watch(_runningTimerProvider(userId));

        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                Text(
                  'CYCLE',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 6),
                if (selectedSprintId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (selectedSprintStatus ?? 'Active'),
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  )
                else
                  Text(
                    ': ',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(width: 8),
                _buildSprintDropdown(context),
                const SizedBox(width: 8),
                runningTimerAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (timerInfo) {
                    if (timerInfo == null || !timerInfo.isRunning) {
                      return const SizedBox.shrink();
                    }

                    DateTime? serverStartTime;
                    try {
                      serverStartTime = DateTime.parse(
                        timerInfo.startTime.replaceFirst(' ', 'T'),
                      );
                    } catch (_) {
                      serverStartTime = DateTime.now();
                    }

                    return _buildRunningTimerButton(
                      context: context,
                      taskName: timerInfo.taskName,
                      rowId: timerInfo.timerId,
                      serverStartTime: serverStartTime,
                      onStopped: () =>
                          ref.invalidate(_runningTimerProvider(userId)),
                    );
                  },
                ),
                if (runningTimerAsync.asData?.value?.isRunning == true)
                  const SizedBox(width: 8),
                if (canManageSprints) ...[
                  _buildAddButton(
                    context: context,
                    label: 'SPRINT',
                    onTap: () {
                      if (selectedProjectId == null ||
                          selectedProjectId!.isEmpty) {
                        showErrorSnackBar(context, 'Please select a project');
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateSprintPage(
                            projectId: selectedProjectId!,
                            projectName: selectedProjectName!,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildAddButton(
                    context: context,
                    label: 'RELEASE',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateReleasePage(
                            projectId: selectedProjectId,
                            projectName: selectedProjectName,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildAddButton(
                    context: context,
                    label: 'EPIC',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateEpicPage(
                            projectId: selectedProjectId ?? widgetProjectId,
                            projectName:
                                selectedProjectName ?? widgetProjectName,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildAddButton(
                    context: context,
                    label: 'STORY',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateStoryPage(
                            projectId: selectedProjectId ?? widgetProjectId,
                            sprintId: selectedSprintId ?? '',
                            sprintNameSelected: selectedSprintName,
                            projectNameSelected: selectedProjectName,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRunningTimerButton({
    required BuildContext context,
    required String taskName,
    required String rowId,
    required DateTime serverStartTime,
    required VoidCallback onStopped,
  }) {
    return GestureDetector(
      onTap: () async {
        final stopped = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => StopTimerPage(
              rowId: rowId,
              serverStartTime: serverStartTime,
              taskName: taskName,
            ),
          ),
        );

        if (stopped == true) {
          onStopped();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.timer, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'Timer Running',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSprintDropdown(BuildContext context) {
    if (selectedProjectId == null || selectedProjectId!.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: greyBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Select Project first',
          style: TextStyle(color: textSecondary),
        ),
      );
    }

    return sprintsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: cardBg),
        child: Text(
          'Loading...',
          style: TextStyle(color: textSecondary, fontSize: 12),
        ),
      ),
      error: (_, __) => Text('Error', style: TextStyle(color: textSecondary)),
      data: (sprints) {
        if (sprints.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '  No sprint        ',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: onSprintTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: greyBorder, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedSprintName ?? 'Select Sprint',
                  style: TextStyle(
                    color: selectedSprintName == null
                        ? textSecondary
                        : textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down, color: textSecondary, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: greyBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: primary, size: 13),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
