import 'package:flutter/material.dart';

class ProjectAnalyticsCard extends StatelessWidget {
  const ProjectAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // constrain chart height so it doesn't overflow on small devices
    final chartHeight = MediaQuery.of(context).size.height * 0.35;
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
                'Project Analytics',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.filter_list),
            ),
            const SizedBox(height: 8),
            Container(
              height: chartHeight,
              child: ListView.separated(
                itemCount: 12,
                separatorBuilder: (ctx, i) => const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  return _MonthAnalyticsRow(monthIndex: index);
                },
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
          ],
        ),
      ),
    );
  }
}

class _MonthAnalyticsRow extends StatelessWidget {
  final int monthIndex;

  const _MonthAnalyticsRow({required this.monthIndex});

  @override
  Widget build(BuildContext context) {
    // Dummy patterns enforcing Open > Working > Closed
    final openData =    [8.0, 7.0, 9.0, 6.0, 8.0, 7.0, 9.0, 8.0, 6.0, 7.0, 8.0, 7.0];
    final workingData = [5.0, 4.0, 6.0, 3.0, 5.0, 4.0, 5.0, 4.0, 3.0, 4.0, 5.0, 4.0];
    final closedData =  [2.0, 2.0, 3.0, 1.0, 2.0, 2.0, 2.0, 2.0, 1.0, 2.0, 2.0, 2.0];

    final open = openData[monthIndex];
    final working = workingData[monthIndex];
    final closed = closedData[monthIndex];

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthName = months[monthIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              monthName,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HorizontalBar(label: 'Open', value: open, color: Colors.green),
                const SizedBox(height: 4),
                _HorizontalBar(label: 'Working', value: working, color: Colors.orange),
                const SizedBox(height: 4),
                _HorizontalBar(label: 'Closed', value: closed, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _HorizontalBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    // scale factor to fit bars nicely (max val is around 9-10)
    final barWidth = (value / 12) * 200.0; 

    return Row(
      children: [
        Container(
          width: barWidth,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.toInt()}',
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
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
