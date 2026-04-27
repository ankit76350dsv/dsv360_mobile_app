import 'package:dsv360/features/sprints/view/pages/story_details_page.dart';
import 'package:flutter/material.dart';
import 'sprint_story.dart';

class StoryCard extends StatelessWidget {
  final SprintStory story;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final String? projectId;

  const StoryCard({
    required this.story,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: greyBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + drag handle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  story.title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              Icon(Icons.drag_indicator,
                  color: textSecondary.withValues(alpha: 0.5), size: 14),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar with completed/total on same line - only show if tasks exist
          if (story.totalTasks > 0)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: story.totalTasks > 0
                          ? story.completedTasks / story.totalTasks
                          : 0,
                      minHeight: 6,
                      backgroundColor: greyBorder,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${story.completedTasks}/${story.totalTasks}',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 0),
          const SizedBox(height: 4),
          // Bottom row: avatar + story label + points
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              
                 
              // Story points badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${story.storyPoints}SP',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              
           
              // Story label
              

              // Avatar
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    story.memberAvatars.isNotEmpty
                        ? story.memberAvatars.first
                        : '?',
                    style: TextStyle(
                        color: primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return LongPressDraggable<SprintStory>(
      data: story,
      delay: const Duration(milliseconds: 120),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: SizedBox(width: 164, child: card),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: GestureDetector(
        onTap: () {
          if (projectId == null || projectId!.isEmpty) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoryDetailsPage(
                storyId: story.id,
                projectId: projectId!,
                storyTitle: story.title,
              ),
            ),
          );
        },
        child: card,
      ),
    );
  }
}
