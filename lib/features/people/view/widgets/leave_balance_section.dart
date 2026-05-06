import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/custom_chip.dart';
import 'package:dsv360/features/people/model/leave_summary.dart';
import 'package:flutter/material.dart';

class LeaveBalanceSection extends StatelessWidget {
  final LeaveSummary leaveSummary;

  const LeaveBalanceSection({super.key, required this.leaveSummary});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Leave Balance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: customColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8.0),
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: [
                _LeaveBalanceItem(
                  title: 'Paid Leaves',
                  usage: '${leaveSummary.usedPaidLeave} days used',
                  badge:
                      '${leaveSummary.remainingPaidLeaves} remaining / ${leaveSummary.totalPaidLeave} total',
                  badgeColor: Colors.green,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _LeaveBalanceItem(
                  title: 'Sick Leaves',
                  usage: '${leaveSummary.usedSickLeave} days used',
                  badge:
                      '${leaveSummary.remainingSickLeaves} remaining / ${leaveSummary.totalSickLeave} total',
                  badgeColor: Colors.orange,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _LeaveBalanceItem(
                  title: 'Unpaid Leaves Used',
                  badge: 'Used: ${leaveSummary.usedUnpaidLeave}',
                  badgeColor: Colors.lightBlue,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                _LeaveBalanceItem(
                  title: 'Total Remaining',
                  badge: '${leaveSummary.remainingTotalLeaves} days',
                  badgeColor: Colors.green,
                  showCheckmark: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaveBalanceItem extends StatelessWidget {
  final String title;
  final String? usage;
  final String badge;
  final Color badgeColor;
  final bool showCheckmark;

  const _LeaveBalanceItem({
    required this.title,
    this.usage,
    required this.badge,
    required this.badgeColor,
    this.showCheckmark = false,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: customColors.textPrimary,
                  ),
                ),
                if (usage != null) ...[
                  const SizedBox(height: 4),
                  Text(usage!, style: const TextStyle(fontSize: 14)),
                ],
              ],
            ),
          ),
          CustomChip(
            label: badge,
            color: badgeColor,
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }
}
