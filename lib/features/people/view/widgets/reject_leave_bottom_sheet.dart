import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/core/widgets/app_snackbar.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:dsv360/features/people/model/leave_details.dart';
import 'package:dsv360/features/people/repositories/leaves_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RejectLeaveBottomSheet extends ConsumerStatefulWidget {
  final LeaveDetails leave;

  const RejectLeaveBottomSheet({super.key, required this.leave});

  @override
  ConsumerState<RejectLeaveBottomSheet> createState() =>
      _RejectLeaveBottomSheetState();
}

class _RejectLeaveBottomSheetState
    extends ConsumerState<RejectLeaveBottomSheet> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const bottomTwoButtonsLoadingKey = 'add_edit_account_key';
    ref.watch(activeUserRepositoryProvider);

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
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
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
                        .state = true;

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
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
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
                          .state = false;
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
