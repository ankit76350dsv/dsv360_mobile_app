import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProjectAnalyticsCard extends StatelessWidget {
  const ProjectAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // constrain chart height so it doesn't overflow on small devices
    final chartHeight = MediaQuery.of(context).size.height * 0.28;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.bar_chart)),
              title: Text(
                'Project Analytics (2025)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.filter_list),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: chartHeight,
                minHeight: 160,
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5,
                  barGroups: _sampleBarGroups(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _bottomTitles,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _LegendDot(color: Colors.green, label: 'Open'),
                SizedBox(width: 8),
                _LegendDot(color: Colors.orange, label: 'Working'),
                SizedBox(width: 8),
                _LegendDot(color: Colors.red, label: 'Closed'),
              ],
            ),
            // Row(children: const [_LegendDot(color: Colors.green, label: 'Open'), SizedBox(width: 12), _LegendDot(color: Colors.orange, label: 'Working'), SizedBox(width: 12), _LegendDot(color: Colors.red, label: 'Closed')])
          ],
        ),
      ),
    );
  }

  static List<BarChartGroupData> _sampleBarGroups() {
    final months = List.generate(12, (i) => i);
    return months.map((m) {
      final value = (m == 5) ? 1.0 : 0.0; // June index 5
      return BarChartGroupData(
        x: m,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 12,
            color: value > 0 ? Colors.orange : Colors.white10,
          ),
        ],
      );
    }).toList();
  }

  static Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10, color: Colors.white54);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final text = months[value.toInt() % months.length];
    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    // return Row(mainAxisAlignment: MainAxisAlignment.center, children: const [_LegendDot(color: Colors.green, label: 'Completed'), SizedBox(width: 8), _LegendDot(color: Colors.orange, label: 'Open'), SizedBox(width: 8), _LegendDot(color: Colors.red, label: 'In Progress')]);
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
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
