
import 'package:dsv360/models/users.dart';
import 'package:flutter/material.dart';


class WorkStatusChip extends StatelessWidget {
  final WorkStatus status;

  const WorkStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;

    switch (status) {
      case WorkStatus.active:
        statusText = "Active";
        statusColor = Colors.green;
        break;
      case WorkStatus.inactive:
        statusText = "Inactive";
        statusColor = const Color.fromARGB(255, 255, 0, 0);
        break;
    }

    return Chip(
      label: Text(statusText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: statusColor.withOpacity(0.7))),
      visualDensity: VisualDensity.compact,
      backgroundColor: statusColor.withOpacity(0.1),
      side: BorderSide(color: statusColor.withOpacity(0.7), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
