import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:dsv360/features/badges/repositories/badge_assignment_repository.dart';
import 'package:dsv360/features/sprints/model/sub_task_model.dart';
import 'package:dsv360/features/sprints/model/task_model.dart';
import 'package:dsv360/features/sprints/repositories/heirarchy_repository.dart';
import 'package:dsv360/features/sprints/repositories/start_timer_repository.dart';
import 'package:dsv360/features/sprints/repositories/time_entry_repository.dart';
import 'package:dsv360/features/sprints/repositories/timer_info_repository.dart';
import 'package:dsv360/features/sprints/view/pages/create_time_entry_page.dart';
import 'package:dsv360/features/sprints/view/pages/stop_timer_page.dart';
import 'package:dsv360/features/time_entry/model/time_entry_model.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _subTaskPageDataProvider = FutureProvider.family<
    ({List<SubTaskModel> subTasks, Map<String, String> userIdToName}),
    ({String projectId, String taskId})>((ref, args) async {
  final hierarchyFuture = ref
      .read(hierarchyRepositoryProvider)
      .fetchHierarchy(projectId: args.projectId);
  final usersFuture =
      ref.read(badgeAssignmentRepositoryProvider).fetchUsers();

  final results = await Future.wait([hierarchyFuture, usersFuture]);
  final hierarchy = results[0] as dynamic;
  final users = results[1] as List<BadgeUser>;

  final subTasks = (hierarchy.subtasks as List<SubTaskModel>)
      .where((s) => s.taskId == args.taskId)
      .toList();

  final userIdToName = <String, String>{};
  for (final u in users) {
    userIdToName[u.userId] = u.fullName;
  }

  return (subTasks: subTasks, userIdToName: userIdToName);
});

final _timeEntriesProvider =
    FutureProvider.family<List<TimeEntry>, String>((ref, taskId) async {
  return ref
      .read(sprintTimeEntryRepositoryProvider)
      .fetchTimeEntriesForTask(taskId: taskId);
});

// ── Page ──────────────────────────────────────────────────────────────────────

class SubTaskPage extends ConsumerStatefulWidget {
  final TaskModel task;
  final String projectId;
  final String projectName;
  final String sprintId;

  const SubTaskPage({
    super.key,
    required this.task,
    required this.projectId,
    required this.projectName,
    required this.sprintId,
  });

  @override
  ConsumerState<SubTaskPage> createState() => _SubTaskPageState();
}

class _SubTaskPageState extends ConsumerState<SubTaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Task-level timer state ─────────────────────────────────────────────────
  bool _taskTimerRunning = false;
  bool _taskTimerFetching = true;
  String? _taskTimerRowId;
  DateTime? _taskTimerStartTime;

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
    _fetchTimerStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTimerStatus() async {
    setState(() => _taskTimerFetching = true);
    try {
      final user = AuthManager.instance.currentUser;
      final userId = user?.id.toString() ?? '';
      if (userId.isEmpty) {
        setState(() => _taskTimerFetching = false);
        return;
      }
      final timerInfo = await ref
          .read(timerInfoRepositoryProvider)
          .getTimerInfo(userId: userId);

      if (!mounted) return;

      final isRunning = timerInfo != null &&
          !timerInfo.message.toLowerCase().contains('not');

      setState(() {
        _taskTimerFetching = false;
        if (isRunning) {
          _taskTimerRunning = true;
          _taskTimerRowId = timerInfo.timerId;
          // Parse server's startTime for accurate elapsed time
          final parsed = DateTime.tryParse(
            timerInfo.startTime.replaceFirst(' ', 'T'),
          );
          _taskTimerStartTime = parsed;
        } else {
          _taskTimerRunning = false;
          _taskTimerRowId = null;
          _taskTimerStartTime = null;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _taskTimerFetching = false);
    }
  }

  Future<void> _startTaskTimer() async {
    setState(() => _taskTimerFetching = true);
    try {
      final user = AuthManager.instance.currentUser;
      final userId = user?.id.toString() ?? '';
      final username =
          '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final result = await ref.read(startTimerRepositoryProvider).startTimer(
            entryDate: today,
            projectId: widget.projectId,
            projectName: widget.projectName,
            sourceType: 'SPRINT_TASK',
            sprintId: widget.sprintId,
            sprintTaskId: widget.task.id,
            storyId: widget.task.storyId,
            taskId: widget.task.id,
            taskName: widget.task.title,
            userId: userId,
            username: username,
          );

      setState(() {
        _taskTimerRowId = result.rowId;
        // For freshly started timers, use DateTime.now() so timer starts from 0
        // (server time is already a few milliseconds old by navigation time)
        _taskTimerStartTime = DateTime.now();
        _taskTimerRunning = true;
        _taskTimerFetching = false;
      });
    } catch (e) {
      setState(() => _taskTimerFetching = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start timer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openStopTaskTimer() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StopTimerPage(
          rowId: _taskTimerRowId!,
          serverStartTime: _taskTimerStartTime!,
          taskName: widget.task.title,
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _taskTimerRunning = false;
        _taskTimerRowId = null;
        _taskTimerStartTime = null;
      });
      ref.invalidate(_timeEntriesProvider(widget.task.id));
    }
    // Re-fetch timer status every time we return from stop page
    await _fetchTimerStatus();
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

  Future<String?> _showStatusSelector({
    required BuildContext context,
    required String current,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color greyBorder,
    required Color primary,
  }) async {
    String? result;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: greyBorder, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _statusOptions.map((s) {
                final isSelected =
                    s['value']!.toLowerCase() == current.toLowerCase();
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    result = s['value'];
                    Navigator.pop(dialogContext);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected
                          ? primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                    ),
                    child: Text(
                      s['label']!,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final textPrimary = customColors.textPrimary ?? Colors.black;
    final textSecondary = customColors.textSecondary ?? Colors.grey;
    final cardBg = customColors.cardBackground ?? Colors.white;
    final greyBorder = customColors.greyBorder ?? Colors.grey.shade300;
    final primary = customColors.primary ?? const Color(0xFF1A56DB);
    final taskStatus = widget.task.status;
    final taskStatusColor = _statusColor(taskStatus);

    final dataArgs = (projectId: widget.projectId, taskId: widget.task.id);
    final dataAsync = ref.watch(_subTaskPageDataProvider(dataArgs));
    final timeEntriesAsync = ref.watch(_timeEntriesProvider(widget.task.id));

    return Scaffold(
      body: Column(
        children: [
          // ── Top Bar ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 8),
            child: TopBar(
              title: 'SubTasks',
              onBack: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              actionIcon: Icons.refresh,
              onInfoTap: () {
                ref.invalidate(_subTaskPageDataProvider(dataArgs));
                ref.invalidate(_timeEntriesProvider(widget.task.id));
              },
            ),
          ),

          // ── Task title + status badge ─────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
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

          // ── Log Time / Start Timer ────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateTimeEntryPage(
                            task: widget.task,
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            storyId: widget.task.storyId,
                            sprintId: widget.sprintId,
                          ),
                        ),
                      );
                      if (result == true) {
                        ref.invalidate(_timeEntriesProvider(widget.task.id));
                      }
                      // Re-fetch timer status on return
                      await _fetchTimerStatus();
                    },
                    icon: Icon(Icons.add, size: 16, color: textPrimary),
                    label: Text(
                      'Log Time (Task)',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: greyBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _taskTimerFetching
                        ? null
                        : _taskTimerRunning
                            ? _openStopTaskTimer
                            : _startTaskTimer,
                    icon: _taskTimerFetching
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : Icon(
                            _taskTimerRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 16,
                            color: Colors.white,
                          ),
                    label: Text(
                      _taskTimerFetching
                          ? 'Loading...'
                          : _taskTimerRunning
                              ? 'Pause Timer'
                              : 'Start Timer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _taskTimerRunning
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF2E7D32),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Status row ────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '  Status   ',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: _StatusButton(
                    current: taskStatus,
                    statusOptions: _statusOptions,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    greyBorder: greyBorder,
                    primary: primary,
                    onShowSelector: (ctx, cur) => _showStatusSelector(
                      context: ctx,
                      current: cur,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      greyBorder: greyBorder,
                      primary: primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),

          // ── Tab Bar ───────────────────────────────────────────────────
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: customColors.tabbarBackground ??
                  Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              isScrollable: false,
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
                  child: dataAsync.when(
                    data: (d) =>
                        Text('SUB-TASKS (${d.subTasks.length})'),
                    loading: () => const Text('SUB-TASKS'),
                    error: (_, __) => const Text('SUB-TASKS'),
                  ),
                ),
                const Tab(child: Text('TIME ENTRIES')),
              ],
            ),
          ),

          // ── Tab Views ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Sub-tasks tab ──────────────────────────────────
                dataAsync.when(
                  loading: () => const Center(child: DsvLoader()),
                  error: (err, _) => _ErrorRetry(
                    message: 'Failed to load sub-tasks',
                    detail: err.toString(),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onRetry: () => ref
                        .invalidate(_subTaskPageDataProvider(dataArgs)),
                  ),
                  data: (data) {
                    final subTasks = data.subTasks;
                    final userIdToName = data.userIdToName;
                    final completedCount = subTasks
                        .where((s) =>
                            s.status.toLowerCase() == 'closed')
                        .length;

                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(
                          _subTaskPageDataProvider(dataArgs)),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                            16, 8, 16, 100),
                        children: [
                          // progress row
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: subTasks.isEmpty
                                        ? 0
                                        : completedCount /
                                            subTasks.length,
                                    backgroundColor: Colors.grey
                                        .withValues(alpha: 0.2),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            primary),
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
                                    borderRadius:
                                        BorderRadius.circular(8),
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

                          if (subTasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              child: Text(
                                'No sub-tasks yet',
                                style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 13),
                              ),
                            )
                          else
                            ...subTasks.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final sub = entry.value;
                              final assigneeName =
                                  sub.assigneeId.isEmpty
                                      ? 'Unassigned'
                                      : userIdToName[
                                              sub.assigneeId] ??
                                          sub.assigneeId;
                              return _SubTaskCard(
                                subTask: sub,
                                index: idx + 1,
                                assigneeName: assigneeName,
                                statusOptions: _statusOptions,
                                cardBg: cardBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                greyBorder: greyBorder,
                                primary: primary,
                                onShowSelector: (ctx, cur) =>
                                    _showStatusSelector(
                                  context: ctx,
                                  current: cur,
                                  cardBg: cardBg,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  greyBorder: greyBorder,
                                  primary: primary,
                                ),
                                task: widget.task,
                                projectId: widget.projectId,
                                projectName: widget.projectName,
                                sprintId: widget.sprintId,
                                onTimeEntryAdded: () => ref.invalidate(
                                  _timeEntriesProvider(widget.task.id),
                                ),
                                onReturnFromPage: _fetchTimerStatus,
                              );
                            }),
                        ],
                      ),
                    );
                  },
                ),

                // ── Time Entries tab ───────────────────────────────
                RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(_timeEntriesProvider(widget.task.id)),
                  child: timeEntriesAsync.when(
                    loading: () => const Center(child: DsvLoader()),
                    error: (err, _) => ListView(
                      children: [
                        _ErrorRetry(
                          message: 'Failed to load time entries',
                          detail: err.toString(),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onRetry: () => ref.invalidate(
                              _timeEntriesProvider(widget.task.id)),
                        ),
                      ],
                    ),
                    data: (entries) => _TimeEntriesTab(
                      entries: entries,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      cardBg: cardBg,
                      greyBorder: greyBorder,
                      primary: primary,
                    ),
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

// ── Status button ─────────────────────────────────────────────────────────────

class _StatusButton extends StatefulWidget {
  final String current;
  final List<Map<String, String>> statusOptions;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final Future<String?> Function(BuildContext, String) onShowSelector;

  const _StatusButton({
    required this.current,
    required this.statusOptions,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    required this.onShowSelector,
  });

  @override
  State<_StatusButton> createState() => _StatusButtonState();
}

class _StatusButtonState extends State<_StatusButton> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = widget.current.toUpperCase();
  }

  String _label(String val) {
    final match = widget.statusOptions.firstWhere(
      (s) => s['value']!.toLowerCase() == val.toLowerCase(),
      orElse: () => {'label': val.replaceAll('_', ' ')},
    );
    return match['label']!.toUpperCase();
  }

  Color _color(String val) {
    switch (val.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _color(_current);
    return GestureDetector(
      onTap: () async {
        final selected =
            await widget.onShowSelector(context, _current);
        if (selected != null) setState(() => _current = selected);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: widget.cardBg,
          border: Border.all(color: widget.greyBorder, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(_current),
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                color: widget.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Sub-task Card ─────────────────────────────────────────────────────────────

class _SubTaskCard extends StatefulWidget {
  final SubTaskModel subTask;
  final int index;
  final String assigneeName;
  final List<Map<String, String>> statusOptions;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final Future<String?> Function(BuildContext, String) onShowSelector;
  final TaskModel task;
  final String projectId;
  final String projectName;
  final String sprintId;
  final VoidCallback onTimeEntryAdded;
  final Future<void> Function() onReturnFromPage;

  const _SubTaskCard({
    required this.subTask,
    required this.index,
    required this.assigneeName,
    required this.statusOptions,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    required this.onShowSelector,
    required this.task,
    required this.projectId,
    required this.projectName,
    required this.sprintId,
    required this.onTimeEntryAdded,
    required this.onReturnFromPage,
  });

  @override
  State<_SubTaskCard> createState() => _SubTaskCardState();
}

class _SubTaskCardState extends State<_SubTaskCard> {
  late String _status;

  // ── SubTask timer state ────────────────────────────────────────────────────
  bool _timerRunning = false;
  bool _timerFetching = false;
  String? _timerRowId;
  DateTime? _timerStartTime;

  @override
  void initState() {
    super.initState();
    _status = widget.subTask.status.toUpperCase();
  }

  Future<void> _startSubTaskTimer() async {
    setState(() => _timerFetching = true);
    try {
      final user = AuthManager.instance.currentUser;
      final userId = user?.id.toString() ?? '';
      final username =
          '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final subTaskName =
          '${widget.task.title} > ${widget.subTask.title}';

      final result = await StartTimerRepository().startTimer(
        entryDate: today,
        projectId: widget.projectId,
        projectName: widget.projectName,
        sourceType: 'SPRINT_SUBTASK',
        sprintId: widget.sprintId,
        sprintTaskId: widget.task.id,
        storyId: widget.task.storyId,
        taskId: widget.task.id,
        taskName: subTaskName,
        userId: userId,
        username: username,
        sprintSubTaskId: widget.subTask.rowId,
      );

      setState(() {
        _timerRowId = result.rowId;
        // For freshly started timers, use DateTime.now() so timer starts from 0
        // (server time is already a few milliseconds old by navigation time)
        _timerStartTime = DateTime.now();
        _timerRunning = true;
        _timerFetching = false;
      });
    } catch (e) {
      setState(() => _timerFetching = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start timer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openStopSubTaskTimer() async {
    final subTaskName = '${widget.task.title} > ${widget.subTask.title}';
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StopTimerPage(
          rowId: _timerRowId!,
          serverStartTime: _timerStartTime!,
          taskName: subTaskName,
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _timerRunning = false;
        _timerRowId = null;
        _timerStartTime = null;
      });
      widget.onTimeEntryAdded();
    }
    // Re-fetch task-level timer status on return
    await widget.onReturnFromPage();
  }

  Color _statusColor(String val) {
    switch (val.toLowerCase()) {
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

  String _statusLabel(String val) {
    final match = widget.statusOptions.firstWhere(
      (s) => s['value']!.toLowerCase() == val.toLowerCase(),
      orElse: () => {'label': val.replaceAll('_', ' ')},
    );
    return match['label']!.toUpperCase();
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
    final statusColor = _statusColor(_status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.cardBg,
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
          // title + badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.subTask.title,
                  style: TextStyle(
                    color: widget.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SubTask-${widget.index}',
                  style: TextStyle(
                    color: widget.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // assignee
          Text(
            widget.assigneeName,
            style: TextStyle(
              color: widget.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // status selector
          Row(
            children: [
              Text(
                'Status :',
                style: TextStyle(
                  color: widget.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final selected = await widget.onShowSelector(
                        context, _status);
                    if (selected != null) {
                      setState(() => _status = selected);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.cardBg,
                      border: Border.all(color: widget.greyBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _statusLabel(_status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down,
                            color: widget.textSecondary, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // time / date + action buttons
          Row(
            children: [
              Text(
                '${_formatDuration(widget.subTask.estimatedHours)}  ${_formatDate(widget.subTask.dueDate)}',
                style: TextStyle(
                  color: widget.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _SmallButton(
                label: '+ LOG TIME',
                color: widget.primary,
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateTimeEntryPage(
                        task: widget.task,
                        projectId: widget.projectId,
                        projectName: widget.projectName,
                        storyId: widget.task.storyId,
                        sprintId: widget.sprintId,
                        sourceType: 'SPRINT_SUBTASK',
                        subTaskId: widget.subTask.rowId,
                      ),
                    ),
                  );
                  if (result == true) widget.onTimeEntryAdded();
                  await widget.onReturnFromPage();
                },
              ),
              const SizedBox(width: 8),
              _timerFetching
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _SmallButton(
                      label: _timerRunning ? 'STOP' : 'TIMER',
                      color: _timerRunning
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF2E7D32),
                      icon: _timerRunning ? Icons.pause : Icons.play_arrow,
                      onTap: _timerRunning
                          ? _openStopSubTaskTimer
                          : _startSubTaskTimer,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Time Entries Tab ──────────────────────────────────────────────────────────

class _TimeEntriesTab extends StatelessWidget {
  final List<TimeEntry> entries;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardBg;
  final Color greyBorder;
  final Color primary;

  const _TimeEntriesTab({
    required this.entries,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardBg,
    required this.greyBorder,
    required this.primary,
  });

  int get _totalMinutes => entries.fold(
      0, (sum, e) => sum + (e.getDurationInHours() * 60).round());

  String _formatTotalTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  Map<DateTime, List<TimeEntry>> _grouped() {
    final map = <DateTime, List<TimeEntry>>{};
    for (final e in entries) {
      final key =
          DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    final sorted = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sorted) k: map[k]!};
  }

  String _dayDuration(List<TimeEntry> dayEntries) {
    final total = dayEntries.fold(
        0, (s, e) => s + (e.getDurationInHours() * 60).round());
    final h = total ~/ 60;
    final m = total % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text('No time entries yet',
            style: TextStyle(color: textSecondary, fontSize: 13)),
      );
    }

    final grouped = _grouped();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // summary tiles
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                value: _formatTotalTime(_totalMinutes),
                label: 'Total Time',
                icon: Icons.schedule_outlined,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primary: primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryTile(
                value: entries.length.toString().padLeft(2, '0'),
                label: 'Entries',
                icon: Icons.adjust_outlined,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primary: primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // grouped date sections
        ...grouped.entries.expand((mapEntry) {
          final date = mapEntry.key;
          final dayEntries = mapEntry.value;
          final dayLabel =
              DateFormat('EEE, d MMM yyyy').format(date);
          return [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 8, top: 4),
              child: Row(
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _dayDuration(dayEntries),
                      style: TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...dayEntries.map((e) => _TimeEntryCard(
                  entry: e,
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  greyBorder: greyBorder,
                  primary: primary,
                )),
            const SizedBox(height: 8),
          ];
        }),
      ],
    );
  }
}

// ── Summary tile ──────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;

  const _SummaryTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon,
              color: primary.withValues(alpha: 0.5), size: 28),
        ],
      ),
    );
  }
}

// ── Time Entry Card ───────────────────────────────────────────────────────────

class _TimeEntryCard extends StatefulWidget {
  final TimeEntry entry;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;

  const _TimeEntryCard({
    required this.entry,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
  });

  @override
  State<_TimeEntryCard> createState() => _TimeEntryCardState();
}

class _TimeEntryCardState extends State<_TimeEntryCard> {
  bool _expanded = false;

  String _formatTime(String t) {
    try {
      final parts = t.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1];
      final period = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      if (h == 0) h = 12;
      return '$h:$m $period';
    } catch (_) {
      return t;
    }
  }

  String _duration() {
    final h = widget.entry.getDurationInHours();
    final totalMin = (h * 60).round();
    final hrs = totalMin ~/ 60;
    final mins = totalMin % 60;
    if (hrs > 0) return '${hrs}h ${mins}m';
    return '${mins}m';
  }

  bool get _isBillable =>
      widget.entry.type.toLowerCase() == 'billable';

  @override
  Widget build(BuildContext context) {
    final billableColor =
        _isBillable ? const Color(0xFF1976D2) : const Color(0xFF9E9E9E);
    final timeRange =
        '${_formatTime(widget.entry.startTime)} - ${_formatTime(widget.entry.endTime)}';
    final note = widget.entry.note.trim();
    final hasLongNote = note.length > 55;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.cardBg,
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.1), width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: note.isEmpty
                    ? Text(
                        'No note',
                        style: TextStyle(
                          color: widget.textSecondary,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Text(
                        note,
                        style: TextStyle(
                          color: widget.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: _expanded ? null : 1,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _duration(),
                  style: TextStyle(
                    color: widget.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          if (hasLongNote && note.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: widget.primary,
                      size: 16,
                    ),
                    Text(
                      _expanded ? 'Collapse' : 'Expand',
                      style: TextStyle(
                        color: widget.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 6),

          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  widget.entry.user.isEmpty
                      ? 'Unknown'
                      : widget.entry.user,
                  style: TextStyle(
                    color: widget.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                timeRange,
                style: TextStyle(
                  color: widget.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: billableColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _isBillable ? 'BILLABLE' : 'NON-BILLABLE',
                  style: TextStyle(
                    color: billableColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Error / Retry ─────────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  final String message;
  final String detail;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onRetry;

  const _ErrorRetry({
    required this.message,
    required this.detail,
    required this.textPrimary,
    required this.textSecondary,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(message,
                style: TextStyle(color: textPrimary, fontSize: 15)),
            const SizedBox(height: 6),
            Text(detail,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text('Retry',
                  style: TextStyle(color: Colors.blue.shade400)),
            ),
          ],
        ),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
