import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task.dart';

class TaskDetailsDialog extends StatelessWidget {
  final Task task;

  const TaskDetailsDialog({super.key, required this.task});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.statusPending;
      case 'In Progress':
        return AppColors.statusInProgress;
      case 'Completed':
        return AppColors.statusCompleted;
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
        maxHeight: screenHeight * 0.75,
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
                'Task Details',
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
                  // Row 1: Task ID and Task Name
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.info_outline,
                          label: 'Task ID',
                          value: task.taskId.length > 4 
                              ? 'T${task.taskId.substring(task.taskId.length - 4)}' 
                              : 'T${task.taskId}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.assignment,
                          label: 'Task Name',
                          value: task.taskName,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Row 2: Assigned To and Project Name
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.person,
                          label: 'Assigned To',
                          value: task.assignedTo ?? 'Not assigned',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.folder_outlined,
                          label: 'Project Name',
                          value: task.projectId,
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
                          value: task.startDate != null ? DateFormat('dd/MM/yy').format(task.startDate!) : 'N/A',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.event,
                          label: 'End Date',
                          value: task.endDate != null ? DateFormat('dd/MM/yy').format(task.endDate!) : 'N/A',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Status (Full width)
                  _buildStatusCard(
                    label: 'Status',
                    value: task.status,
                    color: _getStatusColor(task.status),
                  ),
                  const SizedBox(height: 12),
                  
                  // Type (Full width)
                  _buildTypeCard(
                    label: 'Type',
                    value: task.status,
                  ),
                  const SizedBox(height: 12),
                  
                  // Description if available
                  if (task.description != null && task.description!.isNotEmpty)
                    _buildDetailCard(
                      icon: Icons.description,
                      label: 'Description',
                      value: task.description!,
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
            maxLines: 2,
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
          Icon(Icons.check_circle, color: color, size: 18),
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
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
          Icon(Icons.category, color: AppColors.primary, size: 18),
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
          const SizedBox(width: 8),
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
    );
  }
}
