import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/features/sprints/model/sub_task_model.dart';
import 'package:dsv360/features/sprints/model/task_model.dart';
import 'package:dsv360/features/sprints/repositories/heirarchy_repository.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _subTasksProvider = FutureProvider.family<
    List<SubTaskModel>,
    ({String projectId, String taskId})>((ref, args) async {
  final hierarchy = await ref
      .read(hierarchyRepositoryProvider)
      .fetchHierarchy(projectId: args.projectId);

  return hierarchy.subtasks
      .where((s) => s.taskId == args.taskId)
      .toList();
});

// ── Page ──────────────────────────────────────────────────────────────────────

class SubTaskPage extends ConsumerStatefulWidget {
  final TaskModel task;
  final String projectId;

  const SubTaskPage({
    super.key,
    required this.task,
    required this.projectId,
  });

  @override
  ConsumerState<SubTaskPage> createState() => _SubTaskPageState();
}

class _SubTaskPageState extends ConsumerState<SubTaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Map<String, String>> _statusOptions = [
    {'label': 'Not Started', 'value': 'NOT_STARTED'},
    {'label': 'WIP', 'value': 'WIP'},
    {'label': 'Under Internal Testing', 'value': 'UNDER_INTERNAL_TESTING'},
    {'label': 'Pending Zoho', 'value': 'PENDING_FROM_ZOHO'},
    {'label': 'Pending Client', 'value': 'PENDING_FROM_CLIENT'},
    {'label': 'Released For UAT', 'value': 'RELEASED_FOR_UAT'},
    {'label': 'UAT Approved', 'value': 'UAT_APPROVED_BY_CLIENT'},
    {'label': 'Closed', 'value': 'CLOSED'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        return const Color(0xFF00BCD4);
      case 'uat_approved_by_client':
        return const Color(0xFF4CAF50);
      case 'under_internal_testing':
        return const Color(0xFFFF9800);
      case 'pending_from_zoho':
        return const Color(0xFF9C27B0);
      case 'pending_from_client':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _statusLabel(String value) {
    final match = _statusOptions.firstWhere(
      (s) => s['value']!.toLowerCase() == value.toLowerCase(),
      orElse: () => {'label': value.replaceAll('_', ' ')},
    );
    return match['label']!.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final textPrimary = customColors.textPrimary ?? Colors.black;
    final textSecondary = customColors.textSecondary ?? Colors.grey;
    final primary = customColors.primary ?? const Color(0xFF1A56DB);
    final taskStatus = widget.task.status;
    final taskStatusColor = _statusColor(taskStatus);

    final args = (projectId: widget.projectId, taskId: widget.task.id);
    final subTasksAsync = ref.watch(_subTasksProvider(args));

    return Scaffold(
      body: Column(
        children: [
          // ── Top Bar ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 8),
            child: TopBar(
              title: 'SubTasks',
              onBack: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
          ),

          // ── Task title + status badge ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: taskStatusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel(taskStatus),
                    style: TextStyle(
                      color: taskStatusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Status dropdown row ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Text(
                    'Status :',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatusDropdown(
                      value: taskStatus,
                      options: _statusOptions,
                      statusColor: taskStatusColor,
                      customColors: customColors,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Log Time / Start Timer buttons ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add, size: 16, color: textPrimary),
                    label: Text(
                      'Log Time',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                          color: customColors.greyBorder ?? Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow,
                        size: 16, color: Colors.white),
                    label: const Text(
                      'Start Timer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Tab Bar ───────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: customColors.tabbarBackground ??
                  Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: textSecondary,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
              tabs: [
                Tab(
                  child: subTasksAsync.when(
                    data: (list) => Text('SUB-TASKS (${list.length})'),
                    loading: () => const Text('SUB-TASKS'),
                    error: (_, __) => const Text('SUB-TASKS'),
                  ),
                ),
                const Tab(child: Text('TIME ENTRIES')),
              ],
            ),
          ),

          // ── Tab Views ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Sub-tasks tab ──────────────────────────────────────────
                subTasksAsync.when(
                  loading: () => const Center(child: DsvLoader()),
                  error: (err, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red.shade300),
                          const SizedBox(height: 12),
                          Text('Failed to load sub-tasks',
                              style: TextStyle(
                                  color: textPrimary, fontSize: 15)),
                          const SizedBox(height: 6),
                          Text(err.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: textSecondary, fontSize: 13)),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () =>
                                ref.invalidate(_subTasksProvider(args)),
                            child: Text('Retry',
                                style: TextStyle(
                                    color: Colors.blue.shade400)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (subTasks) {
                    final completedCount = subTasks
                        .where((s) => s.status.toLowerCase() == 'closed')
                        .length;

                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(_subTasksProvider(args)),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        children: [
                          // ── Progress bar row ─────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: subTasks.isEmpty
                                        ? 0
                                        : completedCount / subTasks.length,
                                    backgroundColor:
                                        Colors.grey.withValues(alpha: 0.2),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(primary),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$completedCount/${subTasks.length}',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    '+ ADD SUB-TASK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Sub-task cards ───────────────────────────
                          if (subTasks.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No sub-tasks yet',
                                style: TextStyle(
                                    color: textSecondary, fontSize: 13),
                              ),
                            )
                          else
                            ...subTasks.asMap().entries.map((entry) {
                              final index = entry.key;
                              final subTask = entry.value;
                              return _SubTaskCard(
                                subTask: subTask,
                                index: index + 1,
                                statusOptions: _statusOptions,
                                customColors: customColors,
                                onStatusChanged: (_) {},
                              );
                            }),
                        ],
                      ),
                    );
                  },
                ),

                // ── Time entries tab ───────────────────────────────────────
                Center(
                  child: Text(
                    'No time entries yet',
                    style:
                        TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Dropdown ───────────────────────────────────────────────────────────

class _StatusDropdown extends StatefulWidget {
  final String value;
  final List<Map<String, String>> options;
  final Color statusColor;
  final CustomColors customColors;
  final ValueChanged<String?> onChanged;

  const _StatusDropdown({
    required this.value,
    required this.options,
    required this.statusColor,
    required this.customColors,
    required this.onChanged,
  });

  @override
  State<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = widget.value.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.customColors.greyBorder ?? Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
        color: widget.customColors.cardBackground,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _current,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: widget.customColors.textSecondary, size: 18),
          style: TextStyle(
            color: widget.statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          dropdownColor: widget.customColors.cardBackground,
          items: widget.options
              .map((s) => DropdownMenuItem<String>(
                    value: s['value']!,
                    child: Text(
                      s['label']!.toUpperCase(),
                      style: TextStyle(
                        color: widget.customColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _current = val);
              widget.onChanged(val);
            }
          },
        ),
      ),
    );
  }
}

// ── Sub-task Card ─────────────────────────────────────────────────────────────

class _SubTaskCard extends StatefulWidget {
  final SubTaskModel subTask;
  final int index;
  final List<Map<String, String>> statusOptions;
  final CustomColors customColors;
  final ValueChanged<String?> onStatusChanged;

  const _SubTaskCard({
    required this.subTask,
    required this.index,
    required this.statusOptions,
    required this.customColors,
    required this.onStatusChanged,
  });

  @override
  State<_SubTaskCard> createState() => _SubTaskCardState();
}

class _SubTaskCardState extends State<_SubTaskCard> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.subTask.status.toUpperCase();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'closed':
        return const Color(0xFF4CAF50);
      case 'wip':
        return const Color(0xFF1976D2);
      case 'not_started':
        return const Color(0xFF9E9E9E);
      case 'released_for_uat':
        return const Color(0xFF00BCD4);
      case 'uat_approved_by_client':
        return const Color(0xFF4CAF50);
      case 'under_internal_testing':
        return const Color(0xFFFF9800);
      case 'pending_from_zoho':
        return const Color(0xFF9C27B0);
      case 'pending_from_client':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _formatDuration(double hours) {
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.customColors;
    final statusColor = _statusColor(_status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
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
          // ── Title + badge ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.subTask.title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (colors.primary ?? const Color(0xFF1A56DB))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SubTask-${widget.index}',
                  style: TextStyle(
                    color: colors.primary ?? const Color(0xFF1A56DB),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Assignee ───────────────────────────────────────────────────
          Text(
            widget.subTask.assigneeId.isEmpty
                ? 'Unassigned'
                : widget.subTask.assigneeId,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // ── Status dropdown row ────────────────────────────────────────
          SizedBox(
            height: 36,
            child: Row(
              children: [
                Text(
                  'Status :',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              colors.greyBorder ?? Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: colors.cardBackground,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _status,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: colors.textSecondary, size: 16),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        dropdownColor: colors.cardBackground,
                        items: widget.statusOptions
                            .map((s) => DropdownMenuItem<String>(
                                  value: s['value']!,
                                  child: Text(
                                    s['label']!.toUpperCase(),
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _status = val);
                            widget.onStatusChanged(val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Time / Date + buttons ──────────────────────────────────────
          Row(
            children: [
              Text(
                '${_formatDuration(widget.subTask.estimatedHours)}  ${_formatDate(widget.subTask.dueDate)}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _SmallButton(
                label: '+ LOG TIME',
                color: colors.primary ?? const Color(0xFF1A56DB),
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _SmallButton(
                label: 'TIMER',
                color: const Color(0xFF2E7D32),
                icon: Icons.play_arrow,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small action button ───────────────────────────────────────────────────────

class _SmallButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const _SmallButton({
    required this.label,
    required this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 12),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
