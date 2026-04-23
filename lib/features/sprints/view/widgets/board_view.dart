import 'package:dsv360/features/sprints/view/pages/navigator_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dsv360/core/constants/theme.dart';
import 'sprint_story.dart';
import 'sprint_column.dart';
import 'kanban_column.dart';
import 'progress_stat.dart';
import 'package:intl/intl.dart';

class BoardView extends StatefulWidget {
  final List<SprintStory> stories;
  final void Function(SprintStory, String) onMove;
  final bool isDark;
  final CustomColors customColors;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final double progress;
  final int completedPoints;
  final int totalPoints;
  final int completedStories;
  final int totalStories;
  final String? projectId;
  final String? projectName;
  final String? sprintEndDate;

  const BoardView({
    required this.stories,
    required this.onMove,
    required this.isDark,
    required this.customColors,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    required this.progress,
    required this.completedPoints,
    required this.totalPoints,
    required this.completedStories,
    required this.totalStories,
    this.projectId,
    this.projectName,
    this.sprintEndDate,
  });

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool _isDragging = false;
  double _pointerX = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll(double pointerX, Size size) {
    _isDragging = true;
    _pointerX = pointerX;

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 10),
      (timer) {
        if (!_scrollController.hasClients) return;

        // Scroll right when pointer is near right edge (within 80 pixels)
        if (_pointerX > size.width - 80) {
          _scrollController.jumpTo(
            (_scrollController.offset + 8).clamp(
              0,
              _scrollController.position.maxScrollExtent,
            ),
          );
        }
        // Scroll left when pointer is near left edge (within 80 pixels)
        else if (_pointerX < 80) {
          _scrollController.jumpTo(
            (_scrollController.offset - 8).clamp(
              0,
              _scrollController.position.maxScrollExtent,
            ),
          );
        }
      },
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _isDragging = false;
  }

  int _calculateDaysRemaining() {
    if (widget.sprintEndDate == null || widget.sprintEndDate!.isEmpty) {
      return 0;
    }
    try {
      final endDate = DateFormat('yyyy-MM-dd').parse(widget.sprintEndDate!);
      final now = DateTime.now();
      final difference = endDate.difference(now).inDays;
      return difference;
    } catch (e) {
      return 0;
    }
  }

  String _getDaysLabel() {
    final days = _calculateDaysRemaining();
    if (days == 0) {
      return 'Due today';
    } else if (days < 0) {
      return 'Due exceeded ${-days} ${-days == -1 ? 'day ago' : 'days ago'}';
    } else {
      return '$days ${days == 1 ? 'day left' : 'days left'}';
    }
  }

  Color _getDaysColor() {
    final days = _calculateDaysRemaining();
    if (days == 0) {
      return const Color(0xFFFFC107); // Yellow
    } else if (days < 0) {
      return const Color(0xFFF44336); // Red
    } else {
      return const Color(0xFF4CAF50); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Kanban columns (horizontal scroll) ──
        Expanded(
          child: Listener(
            onPointerMove: (event) {
              if (_isDragging) {
                _startAutoScroll(event.position.dx, context.size ?? Size.zero);
              }
            },
            onPointerUp: (_) {
              _stopAutoScroll();
            },
            onPointerCancel: (_) {
              _stopAutoScroll();
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              itemCount: columns.length,
              itemBuilder: (ctx, i) {
                final col = columns[i];
                final colStories = widget.stories
                    .where((s) => s.columnId == col.id)
                    .toList();
                return KanbanColumn(
                  column: col,
                  stories: colStories,
                  allStories: widget.stories,
                  onMove: widget.onMove,
                  isDark: widget.isDark,
                  cardBg: widget.cardBg,
                  textPrimary: widget.textPrimary,
                  textSecondary: widget.textSecondary,
                  greyBorder: widget.greyBorder,
                  primary: widget.primary,
                  onDragStart: () => setState(() => _isDragging = true),
                  onDragEnd: _stopAutoScroll,
                );
              },
            ),
          ),
        ),

        // ── Progress bar section ──
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.greyBorder, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                    alpha: widget.isDark ? 0.25 : 0.06),
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
                  Text(
                    '${(widget.progress * 100).toStringAsFixed(0)} %',
                    style: TextStyle(
                      color: widget.textPrimary.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  minHeight: 4,
                  backgroundColor: widget.greyBorder,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ProgressStat(
                    label:
                        '${widget.completedPoints}/${widget.totalPoints} SP',
                    color: widget.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  ProgressStat(
                    label:
                        '${widget.completedStories}/${widget.totalStories} Stories',
                    color: widget.textSecondary,
                  ),
                  const Spacer(),
                  ProgressStat(
                    label: _getDaysLabel(),
                    color: _getDaysColor(),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Search + Navigator bottom bar ──
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: Row(
            children: [
              // Search pill
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (widget.projectId == null || widget.projectId!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a project first'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigatorScreen(
                          autoFocusSearch: true,
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.greyBorder.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: widget.customColors.textPrimary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Search stories...',
                          style: TextStyle(
                            color: widget.customColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Navigator pill
              GestureDetector(
                onTap: () {
                  if (widget.projectId == null || widget.projectId!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a project first'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavigatorScreen(
                        projectId: widget.projectId,
                        projectName: widget.projectName,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.greyBorder.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'NAVIGATOR',
                        style: TextStyle(
                          color: widget.customColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: widget.customColors.textPrimary!
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_forward,
                            color: widget.customColors.textPrimary, size: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
