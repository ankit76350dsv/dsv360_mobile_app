import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';

class ProjectDetailsDialog extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailsDialog({super.key, required this.project});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.statusPending;
      case 'Work In Process':
        return AppColors.statusInProgress;
      case 'Completed':
        return AppColors.statusCompleted;
      case 'Closed':
        return AppColors.textSecondary;
      case 'On Hold':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.75, // 75% of screen height
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Project Details',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Row 1: Project ID and Project Name
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.info_outline,
                          label: 'Project ID',
                          value: project.id,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.assignment,
                          label: 'Project Name',
                          value: project.projectName,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Row 2: Assigned To and Client
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.person,
                          label: 'Assigned To',
                          value: project.assignedTo ?? 'Not assigned',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.business,
                          label: 'Client Name',
                          value: project.client,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Row 3: Start Date and End Date
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.calendar_today,
                          label: 'Start Date',
                          value: DateFormat('dd/MM/yy').format(project.startDate),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.event,
                          label: 'End Date',
                          value: DateFormat('dd/MM/yy').format(project.endDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Status Badge (Full width)
                  _buildStatusCard(
                    label: 'Status',
                    value: project.status,
                    color: _getStatusColor(project.status),
                  ),
                  const SizedBox(height: 12),
                  
                  // Progress (Full width)
                  _buildProgressCard(
                    label: 'Progress',
                    value: '${project.progress ?? 0}% completed',
                    progress: (project.progress ?? 0) / 100,
                  ),
                  const SizedBox(height: 12),
                  
                  // Owner if available
                  if (project.owner != null && project.owner!.isNotEmpty)
                    ...[
                      _buildDetailCard(
                        icon: Icons.emoji_events,
                        label: 'Owner',
                        value: project.owner!,
                      ),
                      const SizedBox(height: 12),
                    ],
                  
                  // Description if available
                  if (project.description != null && project.description!.isNotEmpty)
                    _buildDetailCard(
                      icon: Icons.description,
                      label: 'Description',
                      value: project.description!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required String label,
    required String value,
    required double progress,
  }) {
    final isDarkMode = AppColors.background.computeLuminance() < 0.5;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(Icons.trending_up, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDarkMode 
                ? Colors.grey[300]! 
                : Colors.grey[700]!,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  


}
