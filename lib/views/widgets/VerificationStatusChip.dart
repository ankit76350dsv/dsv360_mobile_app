
import 'package:dsv360/models/users.dart';
import 'package:flutter/material.dart';


class VerificationStatusChip extends StatelessWidget {
  final VerificationStatus status;

  const VerificationStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    String statusText;
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case VerificationStatus.verified:
        statusText = "Verified";
        statusIcon = Icons.verified;
        statusColor = Colors.green;
        break;
      case VerificationStatus.pending:
        statusText = "Pending";
        statusIcon = Icons.hourglass_top;
        statusColor = Colors.orange;
        break;
    }

    return Chip(
      label: Text(statusText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: statusColor.withOpacity(0.7))),
      avatar: Icon(statusIcon, size: 16, color: statusColor.withOpacity(0.7),),
      visualDensity: VisualDensity.compact,
      backgroundColor: statusColor.withOpacity(0.1),
      side: BorderSide(color: statusColor.withOpacity(0.7), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
