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
                'Task Status erfger',
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
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(child: Center(child: Text('0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white70)))),
      const Text('Total Tasks', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: const [_LegendDot(color: Colors.green, label: 'Completed'), SizedBox(width: 8), _LegendDot(color: Colors.orange, label: 'Open'), SizedBox(width: 8), _LegendDot(color: Colors.red, label: 'In Progress')])
    ]);
  }
}



class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70))]);
  }
}