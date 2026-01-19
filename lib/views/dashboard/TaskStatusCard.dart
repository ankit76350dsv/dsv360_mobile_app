import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';



class TaskStatusCard extends StatelessWidget {
  const TaskStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.28;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.schedule)),
              title: Text(
                'Task Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.filter_list),
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
                  color: Colors.green,
                  value: 40,
                  title: '40%',
                  radius: 40,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: 30,
                  title: '30%',
                  radius: 40,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: 30,
                  title: '30%',
                  radius: 40,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
            _LegendDot(color: Colors.green, label: 'Completed'),
            SizedBox(height: 8),
            _LegendDot(color: Colors.orange, label: 'Open'),
            SizedBox(height: 8),
            _LegendDot(color: Colors.red, label: 'In Progress'),
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
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70))
    ]);
  }
}