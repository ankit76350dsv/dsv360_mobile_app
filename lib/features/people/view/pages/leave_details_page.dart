import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/people/model/leave_details.dart';
import 'package:dsv360/features/people/model/leave_summary.dart';
import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/features/people/repositories/leave_summary_repository.dart';
import 'package:dsv360/features/people/repositories/leaves_repository.dart';
import 'package:dsv360/core/widgets/app_snackbar.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/people/view/widgets/leave_balance_section.dart';
import 'package:dsv360/features/people/view/widgets/leave_info_box.dart';
import 'package:dsv360/features/people/view/widgets/reject_leave_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveDetailsPage extends ConsumerWidget {
  final LeaveDetails leave;
  final LeaveSummary? leaveSummary;

  const LeaveDetailsPage({super.key, required this.leave, this.leaveSummary});

  final String bottomTwoButtonsLoadingKey = 'leave_details_key';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).custom;
    ref.watch(activeUserRepositoryProvider);

    final leaveSummaryAsync = ref.watch(
      leaveSummaryRepositoryProvider(
        userId: leave.userId,
        username: leave.username,
      ),
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
        title: const Text(
          'Leave Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
                      style: TextStyle(
                        color: customColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 0,
                      childAspectRatio: 2.1,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        LeaveInfoBox(
                          title: 'Leave Type',
                          value: leave.formattedLeaveType,
                          icon: Icons.leave_bags_at_home,
                        ),
                        LeaveInfoBox(
                          title: 'Start Date',
                          value: leave.formattedStartDate,
                          icon: Icons.calendar_month_outlined,
                        ),
                        LeaveInfoBox(
                          title: 'End Date',
                          value: leave.formattedEndDate,
                          icon: Icons.calendar_month_outlined,
                        ),
                        LeaveInfoBox(
                          title: 'Status',
                          value: leave.formattedStatus,
                          icon: Icons.star_outline_sharp,
                        ),
                        LeaveInfoBox(
                          title: 'LeaveCnt',
                          value: leave.formattedLeaveCnt,
                          icon: Icons.format_list_numbered_outlined,
                        ),
                        LeaveInfoBox(
                          title: 'ActionBy',
                          value: leave.formattedActionBy,
                          icon: Icons.ac_unit_outlined,
                        ),
                      ],
                    ),

                    LargeLeaveInfoBox(
                      title: 'Reason',
                      value: leave.formattedReason,
                      icon: Icons.new_releases_outlined,
                    ),

                    LargeLeaveInfoBox(
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
                        message: 'Failed to load data. Please try again.',
                        onRetry: () => ref.refresh(
                          leaveSummaryRepositoryProvider(
                            userId: leave.userId,
                            username: leave.username,
                          ),
                        ),
                      ),
                      data: (LeaveSummary leaveSummary) =>
                          LeaveBalanceSection(leaveSummary: leaveSummary),
                    ),
                    if (IsHaveAccess.instance.isAdmin)
                      const SizedBox(height: 32.0),

                    if ((IsHaveAccess.instance.isAdmin ||
                            IsHaveAccess.instance.isManager) &&
                        leave.status.toLowerCase() == "pending")
                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: "reject",
                        button2Text: "approve",
                        button1Function: () =>
                            _showRejectBottomSheet(context, leave),
                        button2Function: () async {
                          showWarningDialogueBox(
                            context: context,
                            title: 'Approve Leave',
                            subtitle: 'Are you sure you want to approve this leave request from ${leave.username}?',
                            primaryText: 'Approve',
                            onPrimaryPressed: (dialogContext) async {
                              Navigator.pop(dialogContext);
                              
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
                                  .state = true;

                              try {
                                await ref
                                    .read(
                                      leaveDetailsListRepositoryProvider.notifier,
                                    )
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
                                    .state = false;
                              }
                            },
                          );
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
      builder: (context) => RejectLeaveBottomSheet(leave: leave),
    );
  }
}
