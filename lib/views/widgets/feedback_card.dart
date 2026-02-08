import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/feedback_model.dart';

class FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;

  const FeedbackCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: customColors.primary!.withOpacity(0.2),
                  child: Text(
                    feedback.name.isNotEmpty
                        ? feedback.name[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: customColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: customColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feedback.email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: customColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Message
            Text(
              feedback.message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: customColors.textPrimary,
              ),
            ),

            // Images (if any)
            if (feedback.images.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: feedback.images.map((image) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: customColors.inputFill,
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            size: 40,
                            color: customColors.textSecondary,
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: customColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(feedback.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: customColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(feedback.status, context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: customColors.textWhite,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        feedback.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    final customColors = Theme.of(context).custom;
    switch (status.toLowerCase()) {
      case 'in progress':
        return customColors.statusInProgress!;
      case 'completed':
        return customColors.statusCompleted!;
      case 'pending':
        return customColors.statusPending!;
      default:
        return customColors.statusInProgress!;
    }
  }
}
