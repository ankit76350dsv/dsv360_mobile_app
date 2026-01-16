import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/leave_details.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_date_field.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApplyEditLeavePage extends StatefulWidget {
  final LeaveDetails? leave;
  const ApplyEditLeavePage({super.key, required this.leave});

  @override
  State<ApplyEditLeavePage> createState() => _ApplyEditLeavePageState();
}

class _ApplyEditLeavePageState extends State<ApplyEditLeavePage> {
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Leave' : 'Apply Leave',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
      ),
      // backgroundColor: AppColors.bg,
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
                            return 'Enter first name';
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
                        button1Text: "cancel",
                        button2Text: isEditing ? 'SAVE CHANGES' : 'SUBMIT',
                        button1Function: () {
                          Navigator.pop(context);
                        },
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Add / Update user logic
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