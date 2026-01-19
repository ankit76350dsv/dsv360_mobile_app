import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/app_colors.dart';



class TaskStatusCard extends StatelessWidget {
  const TaskStatusCard({super.key});

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
              child: TaskStatusContent(),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskStatusContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                  value: 40,
                  title: '40%',
                  radius: 40,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite),
                ),
                PieChartSectionData(
                  color: AppColors.statusInProgress,
                  value: 30,
                  title: '30%',
                  radius: 40,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite),
                ),
                PieChartSectionData(
                  color: AppColors.error,
                  value: 30,
                  title: '30%',
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
          children: const [
            _LegendDot(color: AppColors.statusCompleted, label: 'Completed'),
            SizedBox(height: 8),
            _LegendDot(color: AppColors.statusInProgress, label: 'Open'),
            SizedBox(height: 8),
            _LegendDot(color: AppColors.error, label: 'In Progress'),
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