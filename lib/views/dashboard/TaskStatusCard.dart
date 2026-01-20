import 'package:dsv360/models/dashboard_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/app_colors.dart';

class TaskStatusCard extends StatelessWidget {
  final YearTaskData taskData;

  const TaskStatusCard({super.key, required this.taskData});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.28;
    return Card(
      elevation: 0,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(Icons.schedule, color: AppColors.textPrimary),
              ),
              title: Text(
                'Task Status',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              trailing: Icon(Icons.filter_list, color: AppColors.textSecondary),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height, minHeight: 140),
              child: TaskStatusContent(taskData: taskData),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskStatusContent extends StatelessWidget {
  final YearTaskData taskData;

  const TaskStatusContent({super.key, required this.taskData});

  @override
  Widget build(BuildContext context) {
    final total = taskData.open + taskData.inProgress + taskData.closed;
    // Avoid division by zero
    final openPct = total == 0 ? 0.0 : (taskData.open / total) * 100;
    final inProgressPct = total == 0 ? 0.0 : (taskData.inProgress / total) * 100;
    final closedPct = total == 0 ? 0.0 : (taskData.closed / total) * 100;

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 30,
              sections: [
                PieChartSectionData(
                  color: AppColors.statusCompleted,
                  value: closedPct,
                  title: '${closedPct.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite),
                ),
                PieChartSectionData(
                  color: AppColors.statusInProgress,
                  value: openPct,
                  title: '${openPct.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite),
                ),
                PieChartSectionData(
                  color: AppColors.error,
                  value: inProgressPct,
                  title: '${inProgressPct.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _LegendDot(color: AppColors.statusCompleted, label: 'Completed (${taskData.closed})'),
            const SizedBox(height: 8),
             _LegendDot(color: AppColors.statusInProgress, label: 'Open (${taskData.open})'),
            const SizedBox(height: 8),
             _LegendDot(color: AppColors.error, label: 'In Progress (${taskData.inProgress})'),
          ],
        ),
      ],
    );
  }
}



class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
    ]);
  }
}