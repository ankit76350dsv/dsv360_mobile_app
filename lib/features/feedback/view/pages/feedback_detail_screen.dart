import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/feedback_model.dart';
import '../../../../views/widgets/TopBar.dart';

class FeedbackDetailScreen extends StatelessWidget {
  final FeedbackModel feedback;

  const FeedbackDetailScreen({
    super.key,
    required this.feedback,
  });

  Color _getStatusColor(String status, BuildContext context) {
    final customColors = Theme.of(context).custom;
    switch (status) {
      case 'Reviewed':
        return customColors.statusCompleted!;
      case 'Pending':
        return customColors.statusPending!;
      case 'In Review':
        return customColors.statusInProgress!;
      default:
        return customColors.textSecondary!;
    }
  }

  Color _getDividerColor(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final isDarkMode = customColors.background!.computeLuminance() < 0.5;
    return isDarkMode 
      ? Colors.white.withValues(alpha: 0.2)
      : customColors.divider!.withValues(alpha: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              title: 'Feedback Details',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Card + Message Card (Merged)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      color: customColors.cardBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: customColors.avatarBackground,
                                  child: Text(
                                    feedback.name.isNotEmpty ? feedback.name[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
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
                                                  )
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  DateFormat('dd MMM yyyy, hh:mm a').format(feedback.date),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: customColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(feedback.status, context).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: _getStatusColor(feedback.status, context),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              feedback.status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _getStatusColor(feedback.status, context),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Divider
                            Divider(color: _getDividerColor(context)),
                            const SizedBox(height: 16),
                            // Feedback Message
                            Text(
                              'Feedback Message',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: customColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              feedback.message,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: customColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Images Section
                    if (feedback.images.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: feedback.images.map((image) {
                          
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(maxHeight: 400),
                                  color: customColors.inputFill,
                                  child: Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 300,
                                        color: customColors.inputFill,
                                        child: Icon(
                                          Icons.image,
                                          size: 60,
                                          color: customColors.textSecondary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
