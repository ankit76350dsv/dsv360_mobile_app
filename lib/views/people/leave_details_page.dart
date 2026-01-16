import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/leave_details.dart';
import 'package:dsv360/models/leave_summary.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
import 'package:flutter/material.dart';

class LeaveDetailsPage extends StatelessWidget {
  final LeaveDetails leave;
  final LeaveSummary? leaveSummary;

  const LeaveDetailsPage({super.key, required this.leave, this.leaveSummary});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Details'),
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Top Grid
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 0,
                      childAspectRatio: 2.1,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _InfoBox(
                          title: 'Leave Type',
                          value: leave.formattedLeaveType,
                          icon: Icons.leave_bags_at_home,
                        ),
                        _InfoBox(
                          title: 'Start Date',
                          value: leave.formattedStartDate,
                          icon: Icons.calendar_month_outlined,
                        ),
                        _InfoBox(
                          title: 'End Date',
                          value: leave.formattedEndDate,
                          icon: Icons.calendar_month_outlined,
                        ),
                        _InfoBox(
                          title: 'Status',
                          value: leave.formattedStatus,
                          icon: Icons.star_outline_sharp,
                        ),
                        _InfoBox(
                          title: 'LeaveCnt',
                          value: leave.formattedLeaveCnt,
                          icon: Icons.format_list_numbered_outlined,
                        ),
                        _InfoBox(
                          title: 'ActionBy',
                          value: leave.formattedActionBy,
                          icon: Icons.ac_unit_outlined,
                        ),
                      ],
                    ),

                    /// Reason
                    _LargeInfoBox(
                      title: 'Reason',
                      value: leave.formattedReason,
                      icon: Icons.new_releases_outlined,
                    ),

                    /// Cancellation Reason
                    _LargeInfoBox(
                      title: 'Cancellation Reason',
                      value: leave.formattedCancellationReason,
                      icon: Icons.new_releases_outlined,
                    ),
                    const SizedBox(height: 20),

                    /// Current Leave Balance Section
                    _LeaveBalanceSection(
                      leaveSummary:
                          leaveSummary ??
                          LeaveSummary.fromJson({
                            "Remaining_Total_Leaves": "24",
                            "Remaining_Paid_Leaves": "20",
                            "Remaining_Sick_Leaves": "4",
                            "Used_Paid_Leave": "0",
                            "Used_Unpaid_Leave": "0",
                            "Used_Sick_Leave": "2",
                            "Total_Sick_Leave": "6",
                            "Total_Paid_Leave": "20",
                          }),
                    ),

                    const SizedBox(height: 32.0),

                    BottomTwoButtons(
                      button1Text: "reject",
                      button2Text: "approve",
                      button1Function: () => _showRejectDialog(context),
                      button2Function: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _RejectLeaveDialog(),
    );
  }
}

class _RejectLeaveDialog extends StatefulWidget {
  const _RejectLeaveDialog();

  @override
  State<_RejectLeaveDialog> createState() => _RejectLeaveDialogState();
}

class _RejectLeaveDialogState extends State<_RejectLeaveDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reject Leave',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please enter your reason for rejecting this leave.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rejection Reason',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Handle reject action with _reasonController.text
                    Navigator.of(context).pop();
                    // TODO: Implement reject leave logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3A3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'REJECT',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small info box (grid items)
class _InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.tertiary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 14.0)),
        ],
      ),
    );
  }
}

/// Large full-width info box
class _LargeInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _LargeInfoBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 14.0)),
          ],
        ),
      ),
    );
  }
}

/// Current Leave Balance Section
class _LeaveBalanceSection extends StatelessWidget {
  final LeaveSummary leaveSummary;

  const _LeaveBalanceSection({required this.leaveSummary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Leave Balance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 8.0),
        Card(
          // color: AppColors.bg,
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

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),

                _LeaveBalanceItem(
                  title: 'Sick Leaves',
                  usage: '${leaveSummary.usedSickLeave} days used',
                  badge:
                      '${leaveSummary.remainingSickLeaves} remaining / ${leaveSummary.totalSickLeave} total',
                  badgeColor: Colors.orange,
                ),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),

                _LeaveBalanceItem(
                  title: 'Unpaid Leaves Used',
                  badge: 'Used: ${leaveSummary.usedUnpaidLeave}',
                  badgeColor: Colors.lightBlue,
                ),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.2),
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

/// Individual leave balance item
class _LeaveBalanceItem extends StatelessWidget {
  final String title;
  final String? usage;
  final String badge;
  final Color badgeColor;
  final bool showCheckmark;
  final IconData? icon;

  const _LeaveBalanceItem({
    required this.title,
    this.usage,
    required this.badge,
    required this.badgeColor,
    this.showCheckmark = false,
    this.icon = Icons.check_circle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
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
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                if (usage != null) ...[
                  const SizedBox(height: 4),
                  Text(usage!, style: TextStyle(fontSize: 14)),
                ],
              ],
            ),
          ),
          CustomChip(label: badge, color: badgeColor, icon: icon),
        ],
      ),
    );
  }
}
