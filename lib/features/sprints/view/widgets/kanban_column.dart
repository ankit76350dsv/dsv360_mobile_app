import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:dsv360/features/sprints/view/pages/create_story_page.dart';
import 'sprint_story.dart';
import 'sprint_column.dart';
import 'story_card.dart';

class KanbanColumn extends StatefulWidget {
  final SprintColumn column;
  final List<SprintStory> stories;
  final List<SprintStory> allStories;
  final void Function(SprintStory, String) onMove;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final String? projectId;
  final String? projectName;
  final String? sprintId;
  final String? sprintName;

  const KanbanColumn({
    required this.column,
    required this.stories,
    required this.allStories,
    required this.onMove,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    this.onDragStart,
    this.onDragEnd,
    this.projectId,
    this.projectName,
    this.sprintId,
    this.sprintName,
  });

  @override
  State<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<KanbanColumn> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<SprintStory>(
      onWillAcceptWithDetails: (details) {
        if (details.data.columnId == widget.column.id) return false;
        setState(() => _isDragOver = true);
        widget.onDragStart?.call();
        return true;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        widget.onMove(details.data, widget.column.id);
        widget.onDragEnd?.call();
      },
      builder: (ctx, candidate, rejected) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 270,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: _isDragOver
                ? widget.column.color.withValues(alpha: 0.1)
                : widget.isDark
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDragOver
                  ? widget.column.color
                  : widget.greyBorder,
              width: _isDragOver ? 2 : 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column header
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.column.title,
                        style: TextStyle(
                          color: widget.column.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: widget.column.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.stories.length}',
                          style: TextStyle(
                            color: widget.column.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Builder(
                      builder: (context) {
                        final roleName = (AuthManager.instance.currentUser?.role?.name ?? '').toLowerCase().trim();
                        final isAdmin = roleName == 'admin' || roleName == 'super admin';
                        if (!isAdmin) return const SizedBox.shrink();
                        return GestureDetector(
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

                            if (widget.sprintId == null || widget.sprintId!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a sprint first'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            final columnToApiStatus = {
                              'not_started': 'NOT_STARTED',
                              'wip': 'WIP',
                              'pending_from_zoho': 'PENDING_FROM_ZOHO',
                              'pending_from_client': 'PENDING_FROM_CLIENT',
                              'released_for_uat': 'RELEASED_FOR_UAT',
                              'uat_approved_by_client': 'UAT_APPROVED_BY_CLIENT',
                              'under_internal_testing': 'UNDER_INTERNAL_TESTING',
                              'closed': 'CLOSED',
                            };

                            final apiStatus = columnToApiStatus[widget.column.id] ?? 'NOT_STARTED';

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateStoryPage(
                                  projectId: widget.projectId,
                                  projectNameSelected: widget.projectName,
                                  sprintId: widget.sprintId,
                                  sprintNameSelected: widget.sprintName,
                                  status: apiStatus,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 2.4, horizontal: 6),
                            decoration: BoxDecoration(
                              color: widget.column.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add, color: widget.column.color, size: 16),
                                Text("Story", style: TextStyle(color: widget.column.color, fontSize: 12),),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Stories list
              Expanded(
                child: widget.stories.isEmpty
                    ? Center(
                        child: Text(
                          'No Items Yet',
                          style: TextStyle(
                            color:
                                widget.textSecondary.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        itemCount: widget.stories.length,
                        itemBuilder: (_, i) => StoryCard(
                          story: widget.stories[i],
                          isDark: widget.isDark,
                          cardBg: widget.cardBg,
                          textPrimary: widget.textPrimary,
                          textSecondary: widget.textSecondary,
                          greyBorder: widget.greyBorder,
                          primary: widget.primary,
                          projectId: widget.projectId,
                          projectName: widget.projectName ?? '',
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
