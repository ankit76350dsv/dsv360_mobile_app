import 'package:dsv360/features/sprints/view/pages/story_details_page.dart';
import 'package:dsv360/features/teams/providers/batch_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sprint_story.dart';

class StoryCard extends ConsumerWidget {
  final SprintStory story;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final String? projectId;
  final String? projectName;

  const StoryCard({
    required this.story,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    this.projectId,
    this.projectName,
  });

  Color _priorityColor(String? priority) {
    switch ((priority ?? '').toUpperCase()) {
      case 'HIGH':
      case 'CRITICAL':
        return const Color(0xFFF44336);
      case 'MEDIUM':
        return const Color(0xFFFFC107);
      case 'LOW':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(batchProfilesProvider);

    String? assigneeProfilePic;
    String assigneeInitials = '?';

    profilesAsync.whenData((profiles) {
      if (story.assigneeId.isNotEmpty) {
        final match = profiles.where((p) => p.userId == story.assigneeId);
        if (match.isNotEmpty) {
          final profile = match.first;
          assigneeProfilePic = profile.profilePic.isNotEmpty ? profile.profilePic : null;
          final first = profile.firstName.isNotEmpty ? profile.firstName[0] : '';
          final last = profile.lastName.isNotEmpty ? profile.lastName[0] : '';
          assigneeInitials = '$first$last'.toUpperCase();
          if (assigneeInitials.isEmpty) assigneeInitials = '?';
        }
      }
    });

    final priorityColor = _priorityColor(story.priority);

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
          // Progress bar — only shown if tasks exist
          if (story.totalTasks > 0)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: story.completedTasks / story.totalTasks,
                      minHeight: 6,
                      backgroundColor: greyBorder,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${story.completedTasks}/${story.totalTasks}',
                  style: TextStyle(color: textSecondary, fontSize: 10),
                ),
              ],
            ),
          const SizedBox(height: 6),
          // Bottom row: priority + story points + assignee avatar
          Row(
            children: [
              // Priority badge
              if (story.priority != null && story.priority!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    story.priority!.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              // Story points badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
              const Spacer(),
              // Assignee avatar
              if (story.assigneeId.isNotEmpty)
                ClipOval(
                  child: assigneeProfilePic != null
                      ? Image.network(
                          assigneeProfilePic!,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 1.2),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/profile.jpg',
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/profile.jpg',
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
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
                projectName: projectName ?? '',
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
