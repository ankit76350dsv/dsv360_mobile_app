import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/feedback_model.dart';
import '../../views/widgets/TopBar.dart';

class FeedbackDetailScreen extends StatelessWidget {
  final FeedbackModel feedback;

  const FeedbackDetailScreen({
    super.key,
    required this.feedback,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Reviewed':
        return AppColors.statusCompleted;
      case 'Pending':
        return AppColors.statusPending;
      case 'In Review':
        return AppColors.statusInProgress;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getDividerColor() {
    final isDarkMode = AppColors.background.computeLuminance() < 0.5;
    return isDarkMode 
      ? Colors.white.withValues(alpha: 0.2)
      : AppColors.divider.withValues(alpha: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      color: AppColors.cardBackground,
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
                                  backgroundColor: AppColors.avatarBackground,
                                  child: Text(
                                    feedback.name.isNotEmpty ? feedback.name[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textWhite,
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
                                                  style: AppTextStyles.cardTitle,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  feedback.email,
                                                  style: AppTextStyles.emailText,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  DateFormat('dd MMM yyyy, hh:mm a').format(feedback.date),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(feedback.status).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: _getStatusColor(feedback.status),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              feedback.status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _getStatusColor(feedback.status),
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
                            Divider(color: _getDividerColor()),
                            const SizedBox(height: 16),
                            // Feedback Message
                            const Text(
                              'Feedback Message',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              feedback.message,
                              style: AppTextStyles.bodyMedium,
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
                        children: feedback.images.asMap().entries.map((entry) {
                          final index = entry.key;
                          // final image = entry.value;
                          
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(maxHeight: 400),
                                  color: AppColors.inputFill,
                                  child: Image.asset(
                                    'assets/images/feedback.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 300,
                                        color: AppColors.inputFill,
                                        child: const Icon(
                                          Icons.image,
                                          size: 60,
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (index < feedback.images.length - 1)
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
