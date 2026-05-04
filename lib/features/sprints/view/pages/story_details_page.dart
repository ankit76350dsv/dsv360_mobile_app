import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/features/badges/repositories/badge_assignment_repository.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/features/sprints/model/sprints_model.dart';
import 'package:dsv360/features/sprints/model/story_model.dart';
import 'package:dsv360/features/sprints/model/task_model.dart';
import 'package:dsv360/features/sprints/repositories/get_sprints_repository.dart';
import 'package:dsv360/features/sprints/repositories/heirarchy_repository.dart';
import 'package:dsv360/features/sprints/view/pages/add_task_page.dart';
import 'package:dsv360/features/sprints/view/pages/edit_story_page.dart';
import 'package:dsv360/features/sprints/view/pages/sub_task_page.dart';
import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _storyDetailsProvider = FutureProvider.family<
    ({StoryModel? story, List<TaskModel> tasks, List<SprintModel> sprints, Map<String, String> userIdToName}),
    ({String projectId, String storyId})>((ref, args) async {
  final hierarchyFuture = ref
      .read(hierarchyRepositoryProvider)
      .fetchHierarchy(projectId: args.projectId);

  final sprintsFuture = ref
      .read(getSprintsRepositoryProvider)
      .fetchSprints(projectId: args.projectId);

  final usersFuture = ref
      .read(badgeAssignmentRepositoryProvider)
      .fetchUsers();

  final results = await Future.wait([hierarchyFuture, sprintsFuture, usersFuture]);
  final hierarchy = results[0] as dynamic;
  final sprints = results[1] as List<SprintModel>;
  final users = results[2] as dynamic;

  final story = (hierarchy.stories as List<StoryModel>)
      .where((s) => s.id == args.storyId)
      .cast<StoryModel?>()
      .firstOrNull;

  final tasks = (hierarchy.tasks as List<TaskModel>)
      .where((t) => t.storyId == args.storyId)
      .toList();

  final userIdToName = <String, String>{};
  for (final user in users) {
    userIdToName[user.userId] = user.fullName;
  }

  return (story: story, tasks: tasks, sprints: sprints, userIdToName: userIdToName);
});

// ── Page ──────────────────────────────────────────────────────────────────────

class StoryDetailsPage extends ConsumerWidget {
  final String storyId;
  final String projectId;
  final String projectName;
  final String? storyTitle;

  const StoryDetailsPage({
    super.key,
    required this.storyId,
    required this.projectId,
    this.projectName = '',
    this.storyTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).custom;
    final textPrimary = customColors.textPrimary ?? Colors.black;
    final textSecondary = customColors.textSecondary ?? Colors.grey;
    final greyBorder = customColors.greyBorder ?? Colors.grey.shade300;
    final primary = customColors.primary ?? const Color(0xFF1A56DB);
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    final dataAsync = ref.watch(_storyDetailsProvider(
      (projectId: projectId, storyId: storyId),
    ));

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 8),
            child: TopBar(
              title: storyTitle != null
                  ? '${_truncate(storyTitle!)} | Story Details'
                  : 'Story Details',
              onBack: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DashboardPage()),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: dataAsync.when(
              loading: () => const Center(child: DsvLoader()),
              error: (err, _) => GlobalError(
                message: 'Something went wrong. Please check your connection.',
                onRetry: () => ref.invalidate(
                  _storyDetailsProvider(
                      (projectId: projectId, storyId: storyId)),
                ),
              ),
              data: (data) {
                final story = data.story;
                final tasks = data.tasks;
                final sprints = data.sprints;
                final userIdToName = data.userIdToName;

                if (story == null) {
                  return Center(
                    child: Text('Story not found',
                        style: TextStyle(
                            color: textSecondary, fontSize: 15)),
                  );
                }

                final sprintName = sprints
                    .where((s) => s.rowId == story.sprintId)
                    .map((s) => s.sprintName)
                    .firstOrNull;

                final completedTaskCount = tasks
                    .where((t) => t.status.toLowerCase() == 'closed')
                    .length;

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(
                    _storyDetailsProvider(
                        (projectId: projectId, storyId: storyId)),
                  ),
                  child: ListView(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      // ── Story title ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                story.title,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: primary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [

                                  Text(
                                    '${story.points.toString()} SP',
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Description (full width) ─────────────────────
                      _buildDetailCard(
                        context: context,
                        icon: Icons.description_outlined,
                        label: 'Description',
                        value: story.description.isEmpty
                            ? 'Not set'
                            : story.description,
                        customColors: customColors,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),

                      // ── Assignee & Sprint row ────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              context: context,
                              icon: Icons.person_outline,
                              label: 'Assignee',
                              value: story.assigneeId.isEmpty
                                  ? 'Not set'
                                  : userIdToName[story.assigneeId] ?? story.assigneeId,
                              customColors: customColors,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              context: context,
                              icon: Icons.loop_outlined,
                              label: 'Sprint',
                              value: sprintName ??
                                  (story.sprintId.isEmpty
                                      ? 'Not set'
                                      : story.sprintId),
                              customColors: customColors,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Status (full width) ──────────────────────────
                      _buildStatusCard(
                        context: context,
                        label: 'Status',
                        value: story.status.isEmpty
                            ? 'Not set'
                            : story.status
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                        rawStatus: story.status,
                        primary: primary,
                        customColors: customColors,
                      ),
                      const SizedBox(height: 12),

                      // ── Group & Module row ───────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              context: context,
                              icon: Icons.folder_outlined,
                              label: 'Group',
                              value: story.groupName.isEmpty
                                  ? 'Not set'
                                  : story.groupName,
                              customColors: customColors,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              context: context,
                              icon: Icons.view_module_outlined,
                              label: 'Module',
                              value: story.moduleName.isEmpty
                                  ? 'Not set'
                                  : story.moduleName,
                              customColors: customColors,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Requirement Type & Billing Type row ──────────
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              context: context,
                              icon: Icons.bug_report_outlined,
                              label: 'Requirement Type',
                              value: story.requirementType.isEmpty
                                  ? 'Not set'
                                  : story.requirementType,
                              customColors: customColors,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              context: context,
                              icon: Icons.receipt_outlined,
                              label: 'Billing Type',
                              value: story.billingType.isEmpty
                                  ? 'Not set'
                                  : story.billingType,
                              customColors: customColors,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Product (full width) ─────────────────────────
                      _buildDetailCard(
                        context: context,
                        icon: Icons.inventory_2_outlined,
                        label: 'Product',
                        value: story.zohoProductName.isEmpty
                            ? 'Not set'
                            : story.zohoProductName,
                        customColors: customColors,
                      ),
                      const SizedBox(height: 12),

                      // ── Primary & Secondary Owner row ────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              context: context,
                              icon: Icons.person_pin_outlined,
                              label: 'Primary Owner',
                              value: story.primaryOwnership.isEmpty
                                  ? 'Not set'
                                  : userIdToName[story.primaryOwnership] ?? story.primaryOwnership,
                              customColors: customColors,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              context: context,
                              icon: Icons.people_outline,
                              label: 'Secondary Owner',
                              value: story.secondaryOwnership.isEmpty
                                  ? 'Not set'
                                  : userIdToName[story.secondaryOwnership] ?? story.secondaryOwnership,
                              customColors: customColors,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── FI Remarks (full width) ──────────────────────
                      _buildDetailCard(
                        context: context,
                        icon: Icons.comment_outlined,
                        label: 'FI Remarks',
                        value: story.fiRemarks.isEmpty
                            ? 'Not set'
                            : story.fiRemarks,
                        customColors: customColors,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),

                      // ── Client Remarks (full width) ──────────────────
                      _buildDetailCard(
                        context: context,
                        icon: Icons.rate_review_outlined,
                        label: 'Client Remarks',
                        value: story.clientRemarks.isEmpty
                            ? 'Not set'
                            : story.clientRemarks,
                        customColors: customColors,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),

                      // ── Tasks section header ─────────────────────────
                      Row(
                        children: [
                          Text(
                            'TASKS',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(),
                          if ((ref.watch(activeUserRepositoryProvider)?.roleName ?? '').toLowerCase().trim() == 'admin' || (ref.watch(activeUserRepositoryProvider)?.roleName ?? '').toLowerCase().trim() == 'super admin')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditStoryPage(
                                          story: story,
                                          projectName: projectName,
                                          sprintName: sprintName,
                                          epicName: null,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      ref.invalidate(_storyDetailsProvider(
                                          (projectId: projectId, storyId: storyId)));
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: customColors.cardBackground,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: (customColors.primary ?? const Color(0xFF2563EB))
                                            .withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Edit Story',
                                      style: TextStyle(
                                        color: customColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddTaskPage(
                                          projectId: projectId,
                                          storyId: story.id,
                                          storyTitle: story.title,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: customColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (customColors.primary ??
                                                  const Color(0xFF2563EB))
                                              .withValues(alpha: 0.3),
                                          blurRadius: 3,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      '+ Add Task',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Task tiles ───────────────────────────────────
                      if (tasks.isEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No tasks yet',
                            style: TextStyle(
                                color: textSecondary, fontSize: 13),
                          ),
                        )
                      else
        ...tasks.map((task) => _TaskTile(
              task: task,
              totalTasks: tasks.length,
              completedTasks: completedTaskCount,
              greyBorder: greyBorder,
              customColors: customColors,
              isLightMode: isLightMode,
              projectId: projectId,
              projectName: projectName,
              sprintId: story.sprintId,
              onTaskStatusChanged: () => ref.invalidate(
                _storyDetailsProvider(
                  (projectId: projectId, storyId: storyId),
                ),
              ),
            )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required CustomColors customColors,
    int maxLines = 2,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: customColors.cardBackground,
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.1), width: 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: customColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: customColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: customColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required BuildContext context,
    required String label,
    required String value,
    required String rawStatus,
    required Color primary,
    required CustomColors customColors,
  }) {
    final color = _statusColor(rawStatus);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: customColors.cardBackground,
        border:
            Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: customColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'closed':
        return const Color(0xFF4CAF50);
      case 'wip':
        return const Color(0xFF1976D2);
      case 'not_started':
      case 'not started':
        return const Color(0xFF9E9E9E);
      case 'released_for_uat':
      case 'released for uat':
        return const Color(0xFF00BCD4);
      case 'uat_approved_by_client':
      case 'uat approved':
        return const Color(0xFF4CAF50);
      case 'under_internal_testing':
      case 'under internal testing':
        return const Color(0xFFFF9800);
      case 'pending_from_zoho':
        return const Color(0xFF9C27B0);
      case 'pending_from_client':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _truncate(String text, {int max = 20}) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}…';
  }
}

// ── Task tile ─────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final int totalTasks;
  final int completedTasks;
  final Color greyBorder;
  final CustomColors customColors;
  final bool isLightMode;
  final String projectId;
  final String projectName;
  final String sprintId;
  final VoidCallback? onTaskStatusChanged;

  const _TaskTile({
    required this.task,
    required this.totalTasks,
    required this.completedTasks,
    required this.greyBorder,
    required this.customColors,
    required this.isLightMode,
    required this.projectId,
    required this.projectName,
    required this.sprintId,
    this.onTaskStatusChanged,
  });

  bool get _isDone => task.status.toLowerCase() == 'closed';

  Color _taskStatusColor() {
    switch (task.status.toLowerCase()) {
      case 'closed':
        return const Color(0xFF4CAF50);
      case 'wip':
        return const Color(0xFF1976D2);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _taskStatusColor();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubTaskPage(
              task: task,
              projectId: projectId,
              projectName: projectName,
              sprintId: sprintId,
              onTaskStatusChanged: onTaskStatusChanged,
            ),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: customColors.cardBackground,
        border:
            Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isDone
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                size: 18,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    color: customColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  
                    decorationColor: customColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.status.isEmpty
                      ? 'No Status'
                      : task.status
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ]
      ),
    ),
    );
  }
}
