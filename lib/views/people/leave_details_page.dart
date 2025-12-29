import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/leave_details.dart';
import 'package:dsv360/models/leave_summary.dart';
import 'package:flutter/material.dart';

class LeaveDetailsPage extends StatelessWidget {
  final LeaveDetails leave;
  final LeaveSummary? leaveSummary;

  const LeaveDetailsPage({super.key, required this.leave, this.leaveSummary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            const _TopHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Top Grid
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _InfoBox(
                          title: 'Leave Type',
                          value: leave.formattedLeaveType,
                        ),
                        _InfoBox(
                          title: 'Start Date',
                          value: leave.formattedStartDate,
                        ),
                        _InfoBox(
                          title: 'End Date',
                          value: leave.formattedEndDate,
                        ),
                        _InfoBox(title: 'Status', value: leave.formattedStatus),
                        _InfoBox(
                          title: 'LeaveCnt',
                          value: leave.formattedLeaveCnt,
                        ),
                        _InfoBox(
                          title: 'ActionBy',
                          value: leave.formattedActionBy,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// Reason
                    _LargeInfoBox(
                      title: 'Reason',
                      value: leave.formattedReason,
                    ),
                    const SizedBox(height: 16),

                    /// Cancellation Reason
                    _LargeInfoBox(
                      title: 'Cancellation Reason',
                      value: leave.formattedCancellationReason,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.red.withOpacity(0.1),
                  highlightColor: Colors.red.withOpacity(0.1),
                ),
                child: TextButton(
                  onPressed: () => _showRejectDialog(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                  child: const Text(
                    'REJECT',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // if (_formKey.currentState!.validate()) {
                  //   // Submit logic
                  // }
                },
                child: const Text(
                  'APPROVE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.successDark, AppColors.primary],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Leave Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small info box (grid items)
class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// Large full-width info box
class _LargeInfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _LargeInfoBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Leave Balance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            // color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white54, width: 1.5),
          ),
          child: Column(
            children: [
              _LeaveBalanceItem(
                title: 'Paid Leaves',
                usage: '${leaveSummary.usedPaidLeave} days used',
                badge:
                    '${leaveSummary.remainingPaidLeaves} remaining / ${leaveSummary.totalPaidLeave} total',
                badgeColor: Colors.green,
              ),
              const Divider(color: Colors.white24, height: 24),
              _LeaveBalanceItem(
                title: 'Sick Leaves',
                usage: '${leaveSummary.usedSickLeave} days used',
                badge:
                    '${leaveSummary.remainingSickLeaves} remaining / ${leaveSummary.totalSickLeave} total',
                badgeColor: Colors.orange,
              ),
              const Divider(color: Colors.white24, height: 24),
              _LeaveBalanceItem(
                title: 'Unpaid Leaves Used',
                badge: 'Used: ${leaveSummary.usedUnpaidLeave}',
                badgeColor: Colors.lightBlue,
              ),
              const Divider(color: Colors.white24, height: 24),
              _LeaveBalanceItem(
                title: 'Total Remaining',
                badge: '${leaveSummary.remainingTotalLeaves} days',
                badgeColor: Colors.green,
                showCheckmark: true,
              ),
            ],
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

  const _LeaveBalanceItem({
    required this.title,
    this.usage,
    required this.badge,
    required this.badgeColor,
    this.showCheckmark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (usage != null) ...[
                const SizedBox(height: 4),
                Text(
                  usage!,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCheckmark) ...[
                Icon(Icons.check_circle, size: 16, color: badgeColor),
                const SizedBox(width: 4),
              ],
              Text(
                badge,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
