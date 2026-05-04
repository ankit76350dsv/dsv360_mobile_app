import 'dart:math' as math;

import 'package:dsv360/features/sprints/model/heirarchy_model.dart';
import 'package:dsv360/features/sprints/model/story_model.dart';
import 'package:dsv360/features/sprints/model/task_model.dart';
import 'package:dsv360/features/sprints/model/sub_task_model.dart';
import 'package:flutter/material.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

const double _kRowHeight = 36.0;
const double _kDayWidth = 32.0;
const double _kHeaderMonthH = 22.0;
const double _kHeaderDayH = 20.0;
const double _kHeaderTotalH = _kHeaderMonthH + _kHeaderDayH;

// ── Color palette for story bars ──────────────────────────────────────────────

const List<Color> _kStoryColors = [
  Color(0xFF1A56DB),
  Color(0xFF7E3AF2),
  Color(0xFF0E9F6E),
  Color(0xFFFF5A1F),
  Color(0xFFE3A008),
  Color(0xFFE74694),
  Color(0xFF0694A2),
  Color(0xFF9B1C1C),
];

Color _storyColor(int index) => _kStoryColors[index % _kStoryColors.length];

// ── Data helpers ───────────────────────────────────────────────────────────────

DateTime? _parseDate(String raw) {
  if (raw.isEmpty) return null;
  try {
    // handles ISO8601: "2026-03-30T00:00:00.000Z", "2026-03-30", etc.
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);
    // fallback: split on '-' or '/'
    final parts = raw.split(RegExp(r'[-/]'));
    if (parts.length >= 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2].split('T').first.trim());
      if (y != null && m != null && d != null) return DateTime(y, m, d);
    }
  } catch (_) {}
  return null;
}

class _StoryBar {
  final String storyId;
  final String label;
  final Color color;
  final DateTime start;
  final DateTime end;
  final int rowIndex;

  const _StoryBar({
    required this.storyId,
    required this.label,
    required this.color,
    required this.start,
    required this.end,
    required this.rowIndex,
  });
}

class _TaskBar {
  final String taskId;
  final String storyId;
  final String label;
  final Color color;
  final DateTime due;
  final int rowIndex;

  const _TaskBar({
    required this.taskId,
    required this.storyId,
    required this.label,
    required this.color,
    required this.due,
    required this.rowIndex,
  });
}

// ── Public widget ─────────────────────────────────────────────────────────────

class TimelineView extends StatefulWidget {
  final HierarchyModel hierarchy;
  final String? sprintId;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final String? sprintStartDate;
  final String? sprintEndDate;
  final String? sprintName;
  final bool canManageSprints;
  final String? currentUserId;

  const TimelineView({
    super.key,
    required this.hierarchy,
    this.sprintId,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    this.sprintStartDate,
    this.sprintEndDate,
    this.sprintName,
    this.canManageSprints = true,
    this.currentUserId,
  });

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final TransformationController _transformController =
      TransformationController();
  final ScrollController _taskScrollController = ScrollController();

  String? _selectedStoryId;
  final Map<String, bool> _expandedStories = {};
  final Map<String, bool> _expandedTasks = {};
  bool _tasksPanelCollapsed = false;

  // Keys for auto-scroll in task section
  final Map<String, GlobalKey> _storyKeys = {};
  final Map<String, GlobalKey> _taskKeys = {};


  @override
  void dispose() {
    _transformController.dispose();
    _taskScrollController.dispose();
    super.dispose();
  }

  // ── Derived data ─────────────────────────────────────────────────────────

  List<StoryModel> get _filteredStories {
    var stories = widget.hierarchy.stories;
    if (widget.sprintId != null && widget.sprintId!.isNotEmpty) {
      stories = stories.where((s) => s.sprintId == widget.sprintId).toList();
    }
    if (!widget.canManageSprints && widget.currentUserId != null) {
      stories = stories.where((s) => s.assigneeId == widget.currentUserId).toList();
    }
    return stories;
  }

  List<_StoryBar> _buildStoryBars(DateTime chartStart, DateTime chartEnd) {
    final stories = _filteredStories;
    final bars = <_StoryBar>[];

    for (int i = 0; i < stories.length; i++) {
      final story = stories[i];
      // Stories don't have dates in the model — use sprint dates as fallback,
      // distributing stories across the sprint range for demo purposes.
      // In production replace with story.startDate / story.endDate when available.
      final sprintStart = _parseDate(widget.sprintStartDate ?? '') ?? chartStart;
      final sprintEnd = _parseDate(widget.sprintEndDate ?? '') ?? chartEnd;
      final sprintTotalDays = math.max(1, sprintEnd.difference(sprintStart).inDays);
      final count = math.max(1, stories.length);
      final segment = math.max(1, (sprintTotalDays / count).round());
      final barStart = sprintStart.add(Duration(days: i * segment));
      final barEnd = barStart.add(Duration(days: segment));

      if (barEnd.isBefore(chartStart) || barStart.isAfter(chartEnd)) continue;

      bars.add(_StoryBar(
        storyId: story.id,
        label: 'Story - ${i + 1}',
        color: _storyColor(i),
        start: barStart.isBefore(chartStart) ? chartStart : barStart,
        end: barEnd.isAfter(chartEnd) ? chartEnd : barEnd,
        rowIndex: i,
      ));
    }
    return bars;
  }

  List<_TaskBar> _buildTaskBarsForStory(
    String storyId,
    int storyRowIndex,
    DateTime chartStart,
    DateTime chartEnd,
  ) {
    final tasks = widget.hierarchy.tasks
        .where((t) => t.storyId == storyId)
        .toList();
    final bars = <_TaskBar>[];

    // Find parent story bar for fallback positioning
    final range = _chartRange();
    final storyBars = _buildStoryBars(range.start, range.end);
    _StoryBar? parentBar;
    try {
      parentBar = storyBars.firstWhere((b) => b.storyId == storyId);
    } catch (_) {}

    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      DateTime? due = _parseDate(task.dueDate);

      // Fallback: spread tasks evenly within parent story bar span
      if (due == null && parentBar != null) {
        final parentSpan = math.max(
            1, parentBar.end.difference(parentBar.start).inDays + 1);
        final offset =
            (parentSpan / math.max(1, tasks.length) * i).round();
        due = parentBar.start.add(Duration(days: offset));
      }
      if (due == null) continue;

      // Clamp to chart bounds
      if (due.isAfter(chartEnd)) due = chartEnd;
      if (due.isBefore(chartStart)) due = chartStart;

      bars.add(_TaskBar(
        taskId: task.id,
        storyId: storyId,
        label: task.title.isNotEmpty ? task.title : 'Task ${i + 1}',
        color: _storyColor(storyRowIndex).withValues(alpha: 0.7),
        due: due,
        rowIndex: storyRowIndex + i + 1,
      ));
    }
    return bars;
  }

  // ── Date range for chart ──────────────────────────────────────────────────

  ({DateTime start, DateTime end}) _chartRange() {
    DateTime start = _parseDate(widget.sprintStartDate ?? '') ??
        DateTime.now().subtract(const Duration(days: 7));
    DateTime end = _parseDate(widget.sprintEndDate ?? '') ??
        DateTime.now().add(const Duration(days: 21));
    start = DateTime(start.year, start.month, 1);
    end = DateTime(end.year, end.month + 1, 0);
    // Guarantee at least 1 day
    if (!end.isAfter(start)) end = start.add(const Duration(days: 30));
    return (start: start, end: end);
  }

  // ── Chart widget ──────────────────────────────────────────────────────────

  Widget _buildChart() {
    final range = _chartRange();
    final chartStart = range.start;
    final chartEnd = range.end;
    final totalDays = chartEnd.difference(chartStart).inDays + 1;

    final stories = _filteredStories;
    final storyBars = _buildStoryBars(chartStart, chartEnd);

    // Build rows: each story is one row; if selected, its tasks are inserted below
    final List<_ChartRow> rows = [];
    for (int i = 0; i < stories.length; i++) {
      final story = stories[i];
      final bar = storyBars.firstWhere(
        (b) => b.storyId == story.id,
        orElse: () => _StoryBar(
          storyId: story.id,
          label: 'Story - ${i + 1}',
          color: _storyColor(i),
          start: chartStart,
          end: chartStart,
          rowIndex: i,
        ),
      );
      rows.add(_ChartRow(type: _RowType.story, storyIndex: i, bar: bar));

      if (_selectedStoryId == story.id) {
        final taskBars = _buildTaskBarsForStory(story.id, i, chartStart, chartEnd);
        for (final tb in taskBars) {
          rows.add(_ChartRow(type: _RowType.task, storyIndex: i, taskBar: tb));
        }
        if (taskBars.isEmpty) {
          rows.add(_ChartRow(type: _RowType.empty, storyIndex: i));
        }
      }
    }

    final totalRowCount = rows.length;
    final chartHeight = totalRowCount * _kRowHeight + _kHeaderTotalH;
    final chartWidth = totalDays * _kDayWidth.toDouble();

    return InteractiveViewer(
      transformationController: _transformController,
      constrained: false,
      minScale: 0.4,
      maxScale: 3.0,
      child: SizedBox(
        width: chartWidth,
        height: chartHeight,
        child: CustomPaint(
          size: Size(chartWidth, chartHeight),
          painter: _GanttPainter(
            rows: rows,
            chartStart: chartStart,
            totalDays: totalDays,
            isDark: widget.isDark,
            greyBorder: widget.greyBorder,
            textPrimary: widget.textPrimary,
            textSecondary: widget.textSecondary,
            selectedStoryId: _selectedStoryId,
          ),
          child: _buildTapLayer(rows, chartStart, totalDays, chartWidth, chartHeight),
        ),
      ),
    );
  }

  Widget _buildTapLayer(
    List<_ChartRow> rows,
    DateTime chartStart,
    int totalDays,
    double chartWidth,
    double chartHeight,
  ) {
    return GestureDetector(
      onTapUp: (details) {
        final dy = details.localPosition.dy - _kHeaderTotalH;
        final rowIndex = (dy / _kRowHeight).floor();
        if (rowIndex < 0 || rowIndex >= rows.length) return;
        final row = rows[rowIndex];

        if (row.type == _RowType.story) {
          final stories = _filteredStories;
          if (row.storyIndex < stories.length) {
            final story = stories[row.storyIndex];
            setState(() {
              if (_selectedStoryId == story.id) {
                _selectedStoryId = null;
              } else {
                _selectedStoryId = story.id;
                _expandedStories[story.id] = true;
              }
            });
            _scrollTaskSectionToStory(story.id);
          }
        } else if (row.type == _RowType.task && row.taskBar != null) {
          final taskId = row.taskBar!.taskId;
          setState(() {
            _expandedTasks[taskId] = !(_expandedTasks[taskId] ?? false);
          });
          _scrollTaskSectionToTask(taskId);
        }
      },
      child: const SizedBox.expand(),
    );
  }

  void _scrollTaskSectionToStory(String storyId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _storyKeys[storyId];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollTaskSectionToTask(String taskId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _taskKeys[taskId];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ── Task navigator section ────────────────────────────────────────────────

  Widget _buildTaskNavigator() {
    final stories = _filteredStories;
    if (stories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No stories in this sprint',
            style: TextStyle(color: widget.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _taskScrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        _storyKeys.putIfAbsent(story.id, () => GlobalKey());
        return _buildStorySection(story, index);
      },
    );
  }

  Widget _buildStorySection(StoryModel story, int storyIndex) {
    final isExpanded = _expandedStories[story.id] ?? false;
    final isSelected = _selectedStoryId == story.id;
    final storyColor = _storyColor(storyIndex);
    final tasks = widget.hierarchy.tasks
        .where((t) => t.storyId == story.id)
        .toList();

    return Container(
      key: _storyKeys[story.id],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? storyColor.withValues(alpha: widget.isDark ? 0.18 : 0.08)
            : widget.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? storyColor : widget.greyBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              setState(() {
                _expandedStories[story.id] = !isExpanded;
                if (!isExpanded) {
                  _selectedStoryId = story.id;
                } else if (_selectedStoryId == story.id) {
                  _selectedStoryId = null;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: storyColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Story - ${storyIndex + 1}',
                          style: TextStyle(
                            color: storyColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          story.title,
                          style: TextStyle(
                            color: widget.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: storyColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${tasks.length} SP',
                      style: TextStyle(
                        color: storyColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? tasks.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'No tasks',
                          style: TextStyle(
                            color: widget.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Column(
                        children: tasks.map((task) {
                          _taskKeys.putIfAbsent(task.id, () => GlobalKey());
                          return _buildTaskTile(task, storyColor);
                        }).toList(),
                      )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(TaskModel task, Color storyColor) {
    final isExpanded = _expandedTasks[task.id] ?? false;
    final subtasks = widget.hierarchy.subtasks
        .where((st) => st.taskId == task.id)
        .toList();

    return Container(
      key: _taskKeys[task.id],
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF2A2A2A)
            : Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.greyBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() => _expandedTasks[task.id] = !isExpanded);
              _scrollTaskSectionToTask(task.id);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank,
                    color: storyColor.withValues(alpha: 0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: widget.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtasks.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: storyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${subtasks.length}',
                        style: TextStyle(
                          color: storyColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: widget.textSecondary,
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded && subtasks.isNotEmpty
                ? Column(
                    children: subtasks
                        .map((st) => _buildSubTaskTile(st, storyColor))
                        .toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTaskTile(SubTaskModel subtask, Color storyColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 12, 4),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark
              ? const Color(0xFF333333)
              : Colors.grey.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: widget.greyBorder.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              Icon(
                Icons.subdirectory_arrow_right,
                color: storyColor.withValues(alpha: 0.5),
                size: 13,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtask.title,
                  style: TextStyle(
                    color: widget.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: widget.greyBorder.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  subtask.status,
                  style: TextStyle(
                    color: widget.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Full-screen overlay ───────────────────────────────────────────────────

  void _openFullscreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullscreenGantt(
          hierarchy: widget.hierarchy,
          sprintId: widget.sprintId,
          isDark: widget.isDark,
          cardBg: widget.cardBg,
          textPrimary: widget.textPrimary,
          textSecondary: widget.textSecondary,
          greyBorder: widget.greyBorder,
          primary: widget.primary,
          sprintStartDate: widget.sprintStartDate,
          sprintEndDate: widget.sprintEndDate,
          sprintName: widget.sprintName,
          canManageSprints: widget.canManageSprints,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final stories = _filteredStories;
    final collapsed = _tasksPanelCollapsed;

    return Column(
      children: [
        // ── Gantt chart section — grows when tasks panel is collapsed ──────
        Expanded(
          flex: collapsed ? 10 : 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gantt View',
                          style: TextStyle(
                            color: widget.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.sprintName ?? 'Sprint',
                          style: TextStyle(
                            color: widget.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (widget.sprintStartDate != null &&
                        widget.sprintEndDate != null) ...[
                      Text(
                        '${_formatDate(widget.sprintStartDate!)}  →  ${_formatDate(widget.sprintEndDate!)}',
                        style: TextStyle(
                          color: widget.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GestureDetector(
                      onTap: () => _openFullscreen(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.greyBorder.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.fullscreen,
                          color: widget.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Chart area
              Expanded(
                child: ClipRect(
                  child: stories.isEmpty
                      ? Center(
                          child: Text(
                            'No stories to display',
                            style: TextStyle(
                              color: widget.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : _buildChart(),
                ),
              ),
            ],
          ),
        ),

        // ── Tasks header bar — always visible, tap to collapse/expand ─────
        GestureDetector(
          onTap: () => setState(() => _tasksPanelCollapsed = !collapsed),
          child: Container(
            color: widget.isDark
                ? const Color(0xFF252525)
                : const Color(0xFFEEEEEE),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 1, thickness: 1, color: widget.greyBorder),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  child: Row(
                    children: [
                      Text(
                        'Tasks',
                        style: TextStyle(
                          color: widget.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: widget.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${stories.length} ${stories.length == 1 ? 'Story' : 'Stories'}',
                          style: TextStyle(
                            color: widget.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Collapse / Expand pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.greyBorder.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              collapsed ? 'Expand' : 'Collapse',
                              style: TextStyle(
                                color: widget.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 3),
                            AnimatedRotation(
                              turns: collapsed ? 0.0 : 0.5,
                              duration: const Duration(milliseconds: 220),
                              child: Icon(
                                Icons.keyboard_arrow_up,
                                color: widget.textSecondary,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Tasks panel — slides in/out from bottom ────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: collapsed
              ? const SizedBox.shrink()
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.38,
                  child: _buildTaskNavigator(),
                ),
        ),
      ],
    );
  }

  String _formatDate(String raw) {
    final d = _parseDate(raw);
    if (d == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')}-${months[d.month - 1]}-${d.year}';
  }
}

// ── Row model for gantt painter ───────────────────────────────────────────────

enum _RowType { story, task, empty }

class _ChartRow {
  final _RowType type;
  final int storyIndex;
  final _StoryBar? bar;
  final _TaskBar? taskBar;

  const _ChartRow({
    required this.type,
    required this.storyIndex,
    this.bar,
    this.taskBar,
  });
}

// ── Custom painter ────────────────────────────────────────────────────────────

class _GanttPainter extends CustomPainter {
  final List<_ChartRow> rows;
  final DateTime chartStart;
  final int totalDays;
  final bool isDark;
  final Color greyBorder;
  final Color textPrimary;
  final Color textSecondary;
  final String? selectedStoryId;

  _GanttPainter({
    required this.rows,
    required this.chartStart,
    required this.totalDays,
    required this.isDark,
    required this.greyBorder,
    required this.textPrimary,
    required this.textSecondary,
    this.selectedStoryId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawBars(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = greyBorder.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    final monthBgPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFF0F0F0);

    final todayPaint = Paint()
      ..color = const Color(0xFF1976D2).withValues(alpha: 0.4)
      ..strokeWidth = 1.5;

    final today = DateTime.now();
    final todayOffset = today.difference(chartStart).inDays;

    // Build month segments
    final months = <({int startDay, int endDay, String label})>[];
    DateTime cursor = chartStart;
    while (cursor.isBefore(DateTime(chartStart.year, chartStart.month + 1, 1)
        .add(Duration(days: totalDays)))) {
      final mStart = DateTime(cursor.year, cursor.month, 1);
      final mEnd = DateTime(cursor.year, cursor.month + 1, 0);
      final startDay = mStart.difference(chartStart).inDays;
      final endDay = mEnd.difference(chartStart).inDays;
      if (startDay > totalDays) break;
      months.add((
        startDay: startDay.clamp(0, totalDays),
        endDay: endDay.clamp(0, totalDays),
        label:
            '${_monthName(cursor.month)} ${cursor.year}',
      ));
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    // Draw month header backgrounds alternating
    for (int mi = 0; mi < months.length; mi++) {
      final m = months[mi];
      if (mi.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(
            m.startDay * _kDayWidth,
            0,
            (m.endDay - m.startDay + 1) * _kDayWidth,
            size.height,
          ),
          monthBgPaint,
        );
      }
    }

    // Draw month labels
    for (final m in months) {
      final tp = TextPainter(
        text: TextSpan(
          text: m.label,
          style: TextStyle(
            color: textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(m.startDay * _kDayWidth + 4, 4),
      );
    }

    // Draw day numbers
    final dayPainterStyle = TextStyle(
      color: textSecondary.withValues(alpha: 0.8),
      fontSize: 8,
    );

    for (int d = 0; d < totalDays; d++) {
      final x = d * _kDayWidth;
      final day = chartStart.add(Duration(days: d));

      // Vertical grid line
      canvas.drawLine(
        Offset(x, _kHeaderTotalH),
        Offset(x, size.height),
        linePaint,
      );

      // Day number
      final tp = TextPainter(
        text: TextSpan(text: '${day.day}', style: dayPainterStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + (_kDayWidth - tp.width) / 2, _kHeaderMonthH + 4),
      );
    }

    // Horizontal row lines
    for (int r = 0; r <= rows.length; r++) {
      final y = _kHeaderTotalH + r * _kRowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Today line
    if (todayOffset >= 0 && todayOffset < totalDays) {
      final x = todayOffset * _kDayWidth + _kDayWidth / 2;
      canvas.drawLine(
        Offset(x, _kHeaderTotalH),
        Offset(x, size.height),
        todayPaint,
      );
    }
  }

  void _drawBars(Canvas canvas, Size size) {
    for (int ri = 0; ri < rows.length; ri++) {
      final row = rows[ri];
      final top = _kHeaderTotalH + ri * _kRowHeight;

      if (row.type == _RowType.story && row.bar != null) {
        _drawStoryBar(canvas, row.bar!, top);
      } else if (row.type == _RowType.task && row.taskBar != null) {
        _drawTaskBar(canvas, row.taskBar!, top);
      } else if (row.type == _RowType.empty) {
        final tp = TextPainter(
          text: TextSpan(
            text: '  No tasks',
            style: TextStyle(
              color: textSecondary.withValues(alpha: 0.6),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(8, top + (_kRowHeight - tp.height) / 2));
      }
    }
  }

  void _drawStoryBar(Canvas canvas, _StoryBar bar, double top) {
    final startOffset = bar.start.difference(chartStart).inDays;
    final endOffset = bar.end.difference(chartStart).inDays + 1;
    final left = startOffset * _kDayWidth;
    final width = (endOffset - startOffset) * _kDayWidth;
    final barTop = top + 4;
    final barBottom = top + _kRowHeight - 4;

    final bgPaint = Paint()..color = bar.color;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, barTop, width, barBottom - barTop),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, bgPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: '  ${bar.label}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 8);
    tp.paint(canvas, Offset(left + 4, barTop + (barBottom - barTop - tp.height) / 2));
  }

  void _drawTaskBar(Canvas canvas, _TaskBar bar, double top) {
    final dueOffset = bar.due.difference(chartStart).inDays;
    final left = dueOffset * _kDayWidth;
    const width = _kDayWidth * 2.5;
    final barTop = top + 5;
    final barBottom = top + _kRowHeight - 5;

    final bgPaint = Paint()..color = bar.color;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, barTop, width, barBottom - barTop),
      const Radius.circular(3),
    );
    canvas.drawRRect(rrect, bgPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: bar.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 4);
    tp.paint(canvas, Offset(left + 2, barTop + (barBottom - barTop - tp.height) / 2));
  }

  String _monthName(int month) {
    const names = [
      '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return names[month];
  }

  @override
  bool shouldRepaint(_GanttPainter old) =>
      old.rows != rows ||
      old.selectedStoryId != selectedStoryId ||
      old.isDark != isDark;
}

// ── Full-screen gantt page ────────────────────────────────────────────────────

class _FullscreenGantt extends StatefulWidget {
  final HierarchyModel hierarchy;
  final String? sprintId;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final String? sprintStartDate;
  final String? sprintEndDate;
  final String? sprintName;
  final bool canManageSprints;
  final String? currentUserId;

  const _FullscreenGantt({
    required this.hierarchy,
    this.sprintId,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    this.sprintStartDate,
    this.sprintEndDate,
    this.sprintName,
    this.canManageSprints = true,
    this.currentUserId,
  });

  @override
  State<_FullscreenGantt> createState() => _FullscreenGanttState();
}

class _FullscreenGanttState extends State<_FullscreenGantt> {
  String? _selectedStoryId;

  List<StoryModel> get _filteredStories {
    var stories = widget.hierarchy.stories;
    if (widget.sprintId != null && widget.sprintId!.isNotEmpty) {
      stories = stories.where((s) => s.sprintId == widget.sprintId).toList();
    }
    if (!widget.canManageSprints && widget.currentUserId != null) {
      stories = stories.where((s) => s.assigneeId == widget.currentUserId).toList();
    }
    return stories;
  }

  ({DateTime start, DateTime end}) _chartRange() {
    DateTime start = _parseDate(widget.sprintStartDate ?? '') ??
        DateTime.now().subtract(const Duration(days: 7));
    DateTime end = _parseDate(widget.sprintEndDate ?? '') ??
        DateTime.now().add(const Duration(days: 21));
    start = DateTime(start.year, start.month, 1);
    end = DateTime(end.year, end.month + 1, 0);
    if (!end.isAfter(start)) end = start.add(const Duration(days: 30));
    return (start: start, end: end);
  }

  List<_StoryBar> _buildStoryBars(DateTime chartStart, DateTime chartEnd) {
    final stories = _filteredStories;
    final bars = <_StoryBar>[];
    final sprintStart = _parseDate(widget.sprintStartDate ?? '') ?? chartStart;
    final sprintEnd = _parseDate(widget.sprintEndDate ?? '') ?? chartEnd;
    final sprintTotalDays = math.max(1, sprintEnd.difference(sprintStart).inDays);
    final count = math.max(1, stories.length);
    for (int i = 0; i < stories.length; i++) {
      final story = stories[i];
      final segment = math.max(1, (sprintTotalDays / count).round());
      final barStart = sprintStart.add(Duration(days: i * segment));
      final barEnd = barStart.add(Duration(days: segment));
      if (barEnd.isBefore(chartStart) || barStart.isAfter(chartEnd)) continue;
      bars.add(_StoryBar(
        storyId: story.id,
        label: 'Story - ${i + 1}',
        color: _storyColor(i),
        start: barStart.isBefore(chartStart) ? chartStart : barStart,
        end: barEnd.isAfter(chartEnd) ? chartEnd : barEnd,
        rowIndex: i,
      ));
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final range = _chartRange();
    final chartStart = range.start;
    final chartEnd = range.end;
    final totalDays = chartEnd.difference(chartStart).inDays + 1;
    final screenSize = MediaQuery.of(context).size;
    final appBarH = kToolbarHeight + MediaQuery.of(context).padding.top;

    final stories = _filteredStories;
    final storyBars = _buildStoryBars(chartStart, chartEnd);

    final List<_ChartRow> rows = [];
    for (int i = 0; i < stories.length; i++) {
      final story = stories[i];
      final bar = storyBars.firstWhere(
        (b) => b.storyId == story.id,
        orElse: () => _StoryBar(
          storyId: story.id,
          label: 'Story - ${i + 1}',
          color: _storyColor(i),
          start: chartStart,
          end: chartStart,
          rowIndex: i,
        ),
      );
      rows.add(_ChartRow(type: _RowType.story, storyIndex: i, bar: bar));

      if (_selectedStoryId == story.id) {
        final tasks = widget.hierarchy.tasks
            .where((t) => t.storyId == story.id)
            .toList();
        final parentBar = bar;
        for (int ti = 0; ti < tasks.length; ti++) {
          final task = tasks[ti];
          DateTime? due = _parseDate(task.dueDate);
          if (due == null) {
            final parentSpan = math.max(
                1, parentBar.end.difference(parentBar.start).inDays + 1);
            final offset =
                (parentSpan / math.max(1, tasks.length) * ti).round();
            due = parentBar.start.add(Duration(days: offset));
          }
          if (due.isAfter(chartEnd)) due = chartEnd;
          if (due.isBefore(chartStart)) due = chartStart;
          rows.add(_ChartRow(
            type: _RowType.task,
            storyIndex: i,
            taskBar: _TaskBar(
              taskId: task.id,
              storyId: story.id,
              label: task.title.isNotEmpty ? task.title : 'Task ${ti + 1}',
              color: _storyColor(i).withValues(alpha: 0.7),
              due: due,
              rowIndex: i + ti + 1,
            ),
          ));
        }
        if (tasks.isEmpty) {
          rows.add(_ChartRow(type: _RowType.empty, storyIndex: i));
        }
      }
    }

    final contentH = rows.length * _kRowHeight + _kHeaderTotalH;
    final chartHeight = math.max(contentH, screenSize.height - appBarH);
    final chartWidth = math.max(
        totalDays * _kDayWidth, screenSize.width);

    return Scaffold(
      backgroundColor: widget.isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: widget.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: widget.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.sprintName ?? 'Timeline',
              style: TextStyle(
                color: widget.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.sprintStartDate != null &&
                widget.sprintEndDate != null)
              Text(
                '${_fmtDate(widget.sprintStartDate!)} → ${_fmtDate(widget.sprintEndDate!)}',
                style: TextStyle(
                  color: widget.textSecondary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: GestureDetector(
            onTapUp: (details) {
              final dy = details.localPosition.dy - _kHeaderTotalH;
              final rowIndex = (dy / _kRowHeight).floor();
              if (rowIndex < 0 || rowIndex >= rows.length) return;
              final row = rows[rowIndex];
              if (row.type == _RowType.story &&
                  row.storyIndex < stories.length) {
                final story = stories[row.storyIndex];
                setState(() {
                  _selectedStoryId =
                      _selectedStoryId == story.id ? null : story.id;
                });
              }
            },
            child: SizedBox(
              width: chartWidth,
              height: chartHeight,
              child: CustomPaint(
                size: Size(chartWidth, chartHeight),
                painter: _GanttPainter(
                  rows: rows,
                  chartStart: chartStart,
                  totalDays: totalDays,
                  isDark: widget.isDark,
                  greyBorder: widget.greyBorder,
                  textPrimary: widget.textPrimary,
                  textSecondary: widget.textSecondary,
                  selectedStoryId: _selectedStoryId,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmtDate(String raw) {
    final d = _parseDate(raw);
    if (d == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')}-${months[d.month - 1]}-${d.year}';
  }
}
