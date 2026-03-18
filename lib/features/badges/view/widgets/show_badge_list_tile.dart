import 'package:dsv360/features/badges/model/badge_summary.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:flutter/material.dart';

class ShowBadgeListTile extends StatelessWidget {
  const ShowBadgeListTile({
    super.key,
    required this.badge,
    required this.isDeleting,
    required this.errorColor,
    required this.onEdit,
    required this.onDelete,
  });

  final BadgeSummary badge;
  final bool isDeleting;
  final Color errorColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade100,
          child: Image.network(
            badge.badgeLogo,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.emoji_events_outlined,
              size: 32,
            ),
          ),
        ),
        title: Text(
          badge.badgeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${badge.badgeLevel} • ${badge.badgeId}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomCardButton(
              onTap: onEdit,
              icon: Icons.edit,
            ),
            const SizedBox(width: 5.0),
            isDeleting
                ? SizedBox(
                    height: 36,
                    width: 36,
                    child: Center(
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: errorColor,
                        ),
                      ),
                    ),
                  )
                : CustomCardButton(
                    onTap: onDelete,
                    icon: Icons.delete,
                    color: errorColor,
                  ),
          ],
        ),
      ),
    );
  }
}
