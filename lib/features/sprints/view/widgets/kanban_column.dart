import 'package:flutter/material.dart';
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
                    GestureDetector(
                      onTap: () {},
                      child: Icon(Icons.add,
                          color: widget.textSecondary, size: 16),
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
