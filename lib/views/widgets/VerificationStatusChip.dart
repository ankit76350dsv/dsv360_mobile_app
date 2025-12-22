
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
      label: Text(statusText, style: const TextStyle(fontSize: 14)),
      avatar: Icon(statusIcon, size: 16),
      visualDensity: VisualDensity.compact,
      backgroundColor: statusColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
