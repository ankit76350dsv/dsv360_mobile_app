import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/leave_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApplyLeavePage extends StatefulWidget {
  final LeaveDetails? leave;
  const ApplyLeavePage({super.key, required this.leave});

  @override
  State<ApplyLeavePage> createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<ApplyLeavePage> {
  final _formKey = GlobalKey<FormState>();

  String? _leaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _reasonController = TextEditingController();

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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopHeader(title: isEditing ? 'Edit Leave' : 'Apply Leave'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Leave Type
                      DropdownButtonFormField<String>(
                        value: _leaveType,
                        decoration: _inputDecoration('Leave Type'),
                        items: const [
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
                        validator: (value) =>
                            value == null ? 'Please select leave type' : null,
                      ),
                      const SizedBox(height: 16),

                      /// Number of Days
                      TextFormField(
                        enabled: false,
                        initialValue: numberOfDays.toString(),
                        decoration: _inputDecoration('Number of days'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      /// Start Date
                      _DateField(
                        label: 'Start Date',
                        date: _startDate,
                        onTap: () => _pickDate(true),
                      ),
                      const SizedBox(height: 16),

                      /// End Date
                      _DateField(
                        label: 'End Date',
                        date: _endDate,
                        onTap: () => _pickDate(false),
                      ),
                      const SizedBox(height: 16),

                      /// Reason
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        decoration: _inputDecoration('Reason'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter reason'
                            : null,
                      ),
                    ],
                  ),
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
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
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
                  if (_formKey.currentState!.validate()) {
                    // Submit logic
                  }
                },
                child: Text(
                  isEditing ? 'SAVE CHANGES' : 'SUBMIT',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

class _TopHeader extends StatelessWidget {
  final String title;
  const _TopHeader({required this.title});

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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
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

/// Date Field Widget
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = date == null
        ? 'dd/mm/yyyy'
        : DateFormat('dd/MM/yyyy').format(date!);

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatted, style: const TextStyle(color: Colors.white)),
            const Icon(Icons.calendar_today, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
