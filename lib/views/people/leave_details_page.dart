import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/models/leave_details.dart';
import 'package:dsv360/models/leave_summary.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/leave_summary_repository.dart';
import 'package:dsv360/repositories/leaves_repository.dart';
import 'package:dsv360/views/widgets/app_snackbar.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveDetailsPage extends ConsumerWidget {
  final LeaveDetails leave;
  final LeaveSummary? leaveSummary;

  const LeaveDetailsPage({super.key, required this.leave, this.leaveSummary});

  final String bottomTwoButtonsLoadingKey = 'leave_details_key';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final userId = activeUser?.userId ?? '';
    final username =
        "${activeUser?.firstName ?? ''} ${activeUser?.lastName ?? ''}".trim();

    final leaveSummaryAsync = ref.watch(
      leaveSummaryRepositoryProvider(userId: userId, username: username),
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Leave Details',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // if needed can add the icon as well here
        // hook for info action
        // you can open a dialog or screen here
        actions: [],
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
                      'Leave Information',
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

                    leaveSummaryAsync.when(
                      loading: () => const GlobalLoader(
                        message: 'Loading leave summary...',
                      ),
                      error: (error, stack) => GlobalError(
                        message: 'Failed to load leave summary data: $error',
                        onRetry: () => ref.refresh(
                          leaveSummaryRepositoryProvider(
                            userId: userId,
                            username: username,
                          ),
                        ),
                      ),
                      data: (LeaveSummary leaveSummary) {
                        /// Current Leave Balance Section
                        return _LeaveBalanceSection(leaveSummary: leaveSummary);
                      },
                    ),

                    const SizedBox(height: 32.0),

                    BottomTwoButtons(
                      loadingKey: bottomTwoButtonsLoadingKey,
                      button1Text: "reject",
                      button2Text: "approve",
                      button1Function: () =>
                          _showRejectBottomSheet(context, leave),
                      button2Function: () async {
                        final activeUser = ref.read(
                          activeUserRepositoryProvider,
                        );
                        if (activeUser == null) return;

                        final actionById = activeUser.userId ?? '';
                        final actionBy =
                            "${activeUser.firstName ?? ''} ${activeUser.lastName ?? ''}"
                                .trim();

                        ref
                                .read(
                                  submitLoadingProvider(
                                    bottomTwoButtonsLoadingKey,
                                  ).notifier,
                                )
                                .state =
                            true;

                        try {
                          await ref
                              .read(leaveDetailsListRepositoryProvider.notifier)
                              .approveLeave(
                                rowId: leave.rowId,
                                actionById: actionById,
                                actionBy: actionBy,
                              );

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            AppSnackBar.show(
                              context,
                              message: 'Leave approved successfully',
                            );
                          }
                        } catch (e) {
                          debugPrint("Error approving leave: $e");
                          if (context.mounted) {
                            AppSnackBar.show(
                              context,
                              message: 'Try again later',
                            );
                          }
                        } finally {
                          ref
                                  .read(
                                    submitLoadingProvider(
                                      bottomTwoButtonsLoadingKey,
                                    ).notifier,
                                  )
                                  .state =
                              false;
                        }
                      },
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

  void _showRejectBottomSheet(BuildContext context, LeaveDetails leave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RejectLeaveBottomSheet(leave: leave),
    );
  }
}

class _RejectLeaveBottomSheet extends ConsumerStatefulWidget {
  final LeaveDetails leave;
  const _RejectLeaveBottomSheet({required this.leave});

  @override
  ConsumerState<_RejectLeaveBottomSheet> createState() =>
      _RejectLeaveBottomSheetState();
}

class _RejectLeaveBottomSheetState
    extends ConsumerState<_RejectLeaveBottomSheet> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    String bottomTwoButtonsLoadingKey = 'add_edit_account_key';

    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Reject Leave',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Please enter your reason for rejecting this leave.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              CustomInputField(
                controller: _rejectionReasonController,
                hintText: 'Enter Rejection Reason',
                labelText: 'Rejection Reason',
                maxLines: 5,
                minLines: 3,
                isMultiline: true,
                prefixIcon: Icons.new_releases_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              BottomTwoButtons(
                loadingKey: bottomTwoButtonsLoadingKey,
                button1Text: "cancel",
                button2Text: "reject",
                button1Function: () => Navigator.of(context).pop(),
                button2Function: () async {
                  if (_formKey.currentState!.validate()) {
                    final activeUser = ref.read(activeUserRepositoryProvider);
                    if (activeUser == null) return;

                    final actionById = activeUser.userId ?? '';
                    final actionBy =
                        "${activeUser.firstName ?? ''} ${activeUser.lastName ?? ''}"
                            .trim();

                    ref
                            .read(
                              submitLoadingProvider(
                                bottomTwoButtonsLoadingKey,
                              ).notifier,
                            )
                            .state =
                        true;

                    try {
                      await ref
                          .read(leaveDetailsListRepositoryProvider.notifier)
                          .rejectLeave(
                            rowId: widget.leave.rowId,
                            actionById: actionById,
                            actionBy: actionBy,
                            cancellationReason: _rejectionReasonController.text,
                          );

                      if (mounted) {
                        Navigator.of(context).pop(); // Close bottom sheet
                        Navigator.of(context).pop(); // Return to list
                        AppSnackBar.show(
                          context,
                          message: 'Leave rejected successfully',
                        );
                      }
                    } catch (e) {
                      debugPrint("Error rejecting leave: $e");
                      if (mounted) {
                        AppSnackBar.show(context, message: 'Try again later');
                      }
                    } finally {
                      ref
                              .read(
                                submitLoadingProvider(
                                  bottomTwoButtonsLoadingKey,
                                ).notifier,
                              )
                              .state =
                          false;
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
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
