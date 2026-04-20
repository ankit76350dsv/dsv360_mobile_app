import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'sprint_story.dart';
import 'sprint_column.dart';
import 'kanban_column.dart';
import 'progress_stat.dart';

class BoardView extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Kanban columns (horizontal scroll) ──
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            itemCount: columns.length,
            itemBuilder: (ctx, i) {
              final col = columns[i];
              final colStories =
                  stories.where((s) => s.columnId == col.id).toList();
              return KanbanColumn(
                column: col,
                stories: colStories,
                allStories: stories,
                onMove: onMove,
                isDark: isDark,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                greyBorder: greyBorder,
                primary: primary,
              );
            },
          ),
        ),

        // ── Progress bar section ──
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: greyBorder, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
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
                    '${(progress * 100).toStringAsFixed(0)} %',
                    style: TextStyle(
                      color: textPrimary.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: greyBorder,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ProgressStat(
                    label: '$completedPoints/$totalPoints SP',
                    color: textSecondary,
                  ),
                  const SizedBox(width: 16),
                  ProgressStat(
                    label: '$completedStories/$totalStories Stories',
                    color: textSecondary,
                  ),
                  const Spacer(),
                  ProgressStat(
                    label: '86 Days left',
                    color: textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Search + Navigator bottom bar ──
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: greyBorder.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Navigate to navigator search page
                  },
                  child: Row(
                    children: [
                      Icon(Icons.search, color: customColors.textPrimary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Search stories...',
                        style: TextStyle(
                          color: customColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: customColors.textPrimary!.withValues(alpha: 0.35),
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to navigator page
                },
                child: Row(
                  children: [
                    Text(
                      'NAVIGATOR',
                      style: TextStyle(
                        color: customColors.textPrimary,
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
                        color: customColors.textPrimary!.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_forward,
                          color: customColors.textPrimary, size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
