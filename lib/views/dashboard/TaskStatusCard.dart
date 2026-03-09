import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/dashboard_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:dsv360/core/constants/app_colors.dart';

class TaskStatusCard extends StatelessWidget {
  final YearTaskData taskData;

  const TaskStatusCard({super.key, required this.taskData});

 

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.28;
    final customColors = Theme.of(context).custom;
   

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: customColors.inputFill,
                child: Icon(Icons.schedule, color: customColors.textPrimary),
              ),
              title: Text(
                
                'Task Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: customColors.textPrimary,
                ),
              ),
              trailing: Icon(
                Icons.filter_list,
                color: customColors.textPrimary!.withOpacity(0.6),
              ),
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
    final custom = Theme.of(context).custom;
    
    // taskData is YearTaskData, passed from dashboard_page.dart via:
    //   TaskStatusCard(taskData: dashboard.yearTaskData)
    // where `dashboard` is a DashboardModel fetched by DashboardRepository
    //   → API: GET .../time_entry_management_application_function/mobile/dashboard
    //   → parsed in DashboardModel.fromJson → json['yearTaskData']
    //   → then YearTaskData.fromJson → keys: 'open', 'in_progress', 'closed'
    final total = taskData.open + taskData.inProgress + taskData.closed;

    debugPrint('📊 TaskStatusCard — open: ${taskData.open}, inProgress: ${taskData.inProgress}, closed: ${taskData.closed}, total: $total');
  
    // Avoid division by zero
    final openPct = total == 0 ? 0.0 : (taskData.open / total) * 100;
    final inProgressPct = total == 0
        ? 0.0
        : (taskData.inProgress / total) * 100;
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
                  color: custom.statusCompleted,
                  value: closedPct,
                  title: '${closedPct.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: custom.statusInProgress,
                  value: openPct,
                  title: '${openPct.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: custom.error,
                  value: inProgressPct,
                  title: '${inProgressPct.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
            _LegendDot(
              color: custom.statusCompleted!,
              label: 'Completed (${taskData.closed})',
            ),
            const SizedBox(height: 8),
            _LegendDot(
              color: custom.statusInProgress!,
              label: 'Open (${taskData.open})',
            ),
            const SizedBox(height: 8),
            _LegendDot(
              color: custom.error!,
              label: 'In Progress (${taskData.inProgress})',
            ),
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
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
