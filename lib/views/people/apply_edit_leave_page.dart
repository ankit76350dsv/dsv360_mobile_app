import 'package:dsv360/models/leave_details.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/leaves_repository.dart';
import 'package:dsv360/views/widgets/app_snackbar.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_date_field.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ApplyEditLeavePage extends ConsumerStatefulWidget {
  final LeaveDetails? leave;
  const ApplyEditLeavePage({super.key, required this.leave});

  @override
  ConsumerState<ApplyEditLeavePage> createState() => _ApplyEditLeavePageState();
}

class _ApplyEditLeavePageState extends ConsumerState<ApplyEditLeavePage> {
  final _formKey = GlobalKey<FormState>();

  String? _leaveType;
  DateTime? _startDate;
  DateTime? _endDate;

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _numberOfDaysLeaveController =
      TextEditingController();

  late bool isEditing;

  int get numberOfDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  String bottomTwoButtonsLoadingKey = 'apply_edit_leave_key';

  @override
  void initState() {
    super.initState();
    isEditing = widget.leave != null;
    if (isEditing) {
      _leaveType = widget.leave!.formattedLeaveType;
      _startDate = DateTime.parse(widget.leave!.startDate);
      _endDate = DateTime.parse(widget.leave!.endDate);
      _reasonController.text = widget.leave!.reason;
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }

        // Auto update number of days if both dates are set
        if (_startDate != null && _endDate != null) {
          _numberOfDaysLeaveController.text = numberOfDays.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

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
          isEditing ? 'Edit Leave' : 'Apply Leave',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // if needed can add the icon as well here
        // hook for info action
        // you can open a dialog or screen here
        actions: [],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
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

                      /// Leave Type
                      CustomDropDownField(
                        hintText: "Select Leave Type",
                        labelText: "Leave Type",
                        prefixIcon: Icons.leave_bags_at_home,
                        selectedOption: _leaveType,
                        options: [
                          DropdownMenuItem(
                            value: 'Sick Leave',
                            child: Text('Sick Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'Paid Leave',
                            child: Text('Paid Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'Unpaid Leave',
                            child: Text('Unpaid Leave'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _leaveType = value),
                      ),
                      const SizedBox(height: 16),

                      /// Number of Days
                      CustomInputField(
                        controller: _numberOfDaysLeaveController,
                        hintText: 'Number of Days',
                        labelText: 'Number of Days',
                        prefixIcon: Icons.calendar_month,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter number of days';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      /// Start Date
                      CustomPickerField(
                        label: 'Start Date',
                        valueText: _startDate == null
                            ? null
                            : DateFormat('dd/MM/yyyy').format(_startDate!),
                        placeholder: 'dd/mm/yyyy',
                        onTap: () => _pickDate(true),
                      ),
                      const SizedBox(height: 16),

                      /// End Date
                      CustomPickerField(
                        label: 'End Date',
                        valueText: _endDate == null
                            ? null
                            : DateFormat('dd/MM/yyyy').format(_endDate!),
                        placeholder: 'dd/mm/yyyy',
                        onTap: () => _pickDate(false),
                      ),
                      const SizedBox(height: 16),

                      /// Reason
                      CustomInputField(
                        controller: _reasonController,
                        hintText: 'Enter Reason',
                        labelText: 'Reason',
                        maxLines: 5,
                        minLines: 4,
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
                      // buttons
                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: "cancel",
                        button2Text: isEditing ? 'SAVE CHANGES' : 'SUBMIT',
                        button1Function: () {
                          Navigator.pop(context);
                        },
                        button2Function: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_startDate == null || _endDate == null) {
                              AppSnackBar.show(
                                context,
                                message: 'Please select start and end dates',
                              );
                              return;
                            }

                            if (_leaveType == null) {
                              AppSnackBar.show(
                                context,
                                message: 'Please select leave type',
                              );
                              return;
                            }

                            final activeUser = ref.read(
                              activeUserRepositoryProvider,
                            );
                            if (activeUser == null) return;

                            final userId = activeUser.userId ?? '';
                            final username =
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
                              if (isEditing) {
                                await ref
                                    .read(
                                      leaveDetailsListRepositoryProvider
                                          .notifier,
                                    )
                                    .updateLeave(
                                      rowId: widget.leave!.rowId,
                                      userId: userId,
                                      username: username,
                                      leaveType: _leaveType!,
                                      reason: _reasonController.text,
                                      startDate: DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_startDate!),
                                      endDate: DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_endDate!),
                                      leaveCnt:
                                          _numberOfDaysLeaveController.text,
                                    );
                              } else {
                                await ref
                                    .read(
                                      leaveDetailsListRepositoryProvider
                                          .notifier,
                                    )
                                    .requestLeave(
                                      userId: userId,
                                      username: username,
                                      leaveType: _leaveType!,
                                      reason: _reasonController.text,
                                      startDate: DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_startDate!),
                                      endDate: DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_endDate!),
                                      leaveCnt:
                                          _numberOfDaysLeaveController.text,
                                    );
                              }

                              if (mounted) {
                                Navigator.pop(context);
                                AppSnackBar.show(
                                  context,
                                  message: isEditing
                                      ? 'Leave updated successfully'
                                      : 'Leave request submitted successfully',
                                );
                              }
                            } catch (e) {
                              debugPrint("Error requesting leave: $e");
                              if (mounted) {
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
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white54),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
