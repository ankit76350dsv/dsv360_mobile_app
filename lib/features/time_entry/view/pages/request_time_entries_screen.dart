import 'dart:convert';

import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/time_entry/model/time_entry_model.dart';
import 'package:dsv360/features/time_entry/view/pages/timer_service.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestTimeEntriesScreen extends StatefulWidget {
  final String currentUser;
  final TimeEntry? editingEntry; // For editing existing entry

  const RequestTimeEntriesScreen({
    super.key,
    this.editingEntry,
    required this.currentUser,
  });

  @override
  State<RequestTimeEntriesScreen> createState() =>
      _RequestTimeEntriesScreenState();
}

class _RequestTimeEntriesScreenState extends State<RequestTimeEntriesScreen> {
  late TextEditingController _userController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _noteController;

  late TextEditingController _projectIdController;
  late TextEditingController _projectNameController;
  late TextEditingController _taskIdController;
  late TextEditingController _taskNameController;
  String _selectedType = 'Non-Billable';
  bool _isLoading = false;

  final List<String> _typeOptions = ['Billable', 'Non-Billable'];

  DateTime? _selectedDate;

  // ADD THIS LIST
  final List<TimeEntry> _entries = [];


bool _isSubmitDisabled() {
  final isFormDirty =
      _startTimeController.text.isNotEmpty ||
      _endTimeController.text.isNotEmpty ||
      _noteController.text.isNotEmpty;

  return isFormDirty || _entries.isEmpty;
}
bool _isAddDisabled() {
  return _startTimeController.text.isEmpty || _noteController.text.isEmpty||
      _endTimeController.text.isEmpty;
}

  void _addTimeEntry() {
  if (_selectedDate == null ||
      _startTimeController.text.isEmpty ||
      _endTimeController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all required fields")),
    );
    return;
  }

  // 🔹 Convert "hh:mm AM/PM" → minutes
  int _convertToMinutes(String time) {
    final parts = time.split(' ');
    final timePart = parts[0];
    final period = parts[1];

    final hourMinute = timePart.split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return hour * 60 + minute;
  }

  final newStart = _convertToMinutes(_startTimeController.text);
  final newEnd = _convertToMinutes(_endTimeController.text);

  // ❌ Invalid range
  if (newEnd <= newStart) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("End time must be after start time")),
    );
    return;
  }

  // 🔴 CHECK OVERLAP
  for (final entry in _entries) {
    if (DateFormat('dd-MM-yyyy').format(entry.date) ==
        DateFormat('dd-MM-yyyy').format(_selectedDate!)) {

      final existingStart = _convertToMinutes(entry.startTime);
      final existingEnd = _convertToMinutes(entry.endTime);

      final isOverlapping =
          newStart < existingEnd && newEnd > existingStart;

      if (isOverlapping) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Time overlaps with existing entry")),
        );
        return;
      }
    }
  }

  final newEntry = TimeEntry(
    id: "fwef",
    user: "zmeraj",
    date: _selectedDate!,
    startTime: _startTimeController.text,
    endTime: _endTimeController.text,
    type: _selectedType,
    note: _noteController.text,
  );

  setState(() {
    _entries.add(newEntry);

    _startTimeController.clear();
    _endTimeController.clear();
    _noteController.clear();
    _selectedType = 'Non-Billable';
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Entry added (${_entries.length})")),
  );
}

  void _saveAllEntries() {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add at least one entry")));
      return;
    }

    // Get user data
    final userId = AuthManager.instance.currentUser?.id ?? '';
    final firstName = AuthManager.instance.currentUser?.firstName ?? '';
    final lastName = AuthManager.instance.currentUser?.lastName ?? '';
    final username = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : widget.currentUser;

    final List<Map<String, dynamic>> jsonEntries = _entries.map((entry) {
  int _convertToMinutes(String time) {
    final parts = time.split(' ');
    final timePart = parts[0];
    final period = parts[1];

    final hourMinute = timePart.split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return hour * 60 + minute;
  }

  final start = _convertToMinutes(entry.startTime);
  final end = _convertToMinutes(entry.endTime);

  return {
    "Username": username,
    "User_ID": userId,
    "Entry_Date": DateFormat('yyyy-MM-dd').format(entry.date),
    "Note": entry.note,
    "Type": entry.type,
    "Start_time": entry.startTime,
    "End_time": entry.endTime,
    "Total_time": end - start,
    "Task_ID": _taskIdController.text,
    "Task_Name": _taskNameController.text,
    "Project_ID": _projectIdController.text,
    "Project_Name": _projectNameController.text,
  };
}).toList();
final String timeentryDataString = jsonEncode(jsonEntries);

    // Create complete request object
    final Map<String, dynamic> requestData = {
      'ApproveByID': '',
      'ApproveDate': '',
      'ApprovedBy': '',
      'Project_ID': _projectIdController.text, // Get from form or state
      'Project_Name': _projectNameController.text, // Get from form or state
      'Reason': '',
      'Rejected': false,
      'Status': 'Pending',
      'Task_Id': _taskIdController.text, // Get from form or state
      'Task_Name': _taskNameController.text, // Get from form or state
      'Timeentry_Data': timeentryDataString,
      'User_Id': userId,
      'Username': username,
    };

    final String finalJsonString = jsonEncode(requestData);

    debugPrint('Complete Request: $finalJsonString');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${_entries.length} entries ready to send")),
    );

    // Todo: Send finalJsonString to server API
  }

  Future<void> _selectDate(BuildContext context) async {
    final customColors = Theme.of(context).custom;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // cutoff = today - 6 days
    final DateTime cutoffDate = today.subtract(const Duration(days: 6));

    final DateTime? pickedDate = await showDatePicker(
  context: context,
  initialDate: cutoffDate.subtract(const Duration(days: 1)), // valid default
  firstDate: DateTime(2000), // or any old date
  lastDate: cutoffDate.subtract(const Duration(days: 1)), // 🔴 KEY CHANGE
  builder: (context, child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.dark(
          primary: customColors.primary!,
          onPrimary: Colors.white,
          surface: customColors.cardBackground!,
          onSurface: customColors.textPrimary!,
        ),
        dialogBackgroundColor: customColors.cardBackground!,
      ),
      child: child!,
    );
  },
);
    if (pickedDate != null) {
      // Validate that the selected date is within the last 7 days
      if (pickedDate.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can only add time entries for the last 7 days'),
            backgroundColor: customColors.error,
          ),
        );
        return;
      }

      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  /// Convert TimeOfDay to 12-hour AM/PM format (e.g., "3:35 PM")
  String _timeOfDayToAMPM(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final customColors = Theme.of(context).custom;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: customColors.primary!,
              onPrimary: Colors.white,
              surface: customColors.cardBackground!,
              onSurface: customColors.textPrimary!,
            ),
            dialogBackgroundColor: customColors.cardBackground!,
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      final time = _timeOfDayToAMPM(pickedTime);
      setState(() {
        if (isStartTime) {
          _startTimeController.text = time;
        } else {
          _endTimeController.text = time;
        }
      });
    }
  }

  

  @override
  void initState() {
    // Todo: implement initState
    super.initState();

    final firstName = AuthManager.instance.currentUser?.firstName ?? '';
    final lastName = AuthManager.instance.currentUser?.lastName ?? '';
    final loggedInUser = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : widget.currentUser;
    _userController = TextEditingController(
      text: loggedInUser,
    ); //replace it with dynamic value later
    _dateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _noteController = TextEditingController();

    _projectIdController = TextEditingController();
    _projectNameController = TextEditingController();
    _taskIdController = TextEditingController();
    _taskNameController = TextEditingController();

    _selectedDate = DateTime.now();
    _selectedType = 'Non-Billable';

    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);

    if (widget.editingEntry != null) {
      final entry = widget.editingEntry!;
      _selectedDate = entry.date;
      _dateController.text = DateFormat('dd-MM-yyyy').format(entry.date);
      _startTimeController.text = entry.startTime;
      _endTimeController.text = entry.endTime;
      _selectedType = entry.type;
      _noteController.text = entry.note;
      _userController.text = loggedInUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Scaffold(
      backgroundColor: customColors.background,

      //app bar here
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: TopBar(
            title: ' add dynamic widget code here - Time Entries',
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),

      //body here
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User field (read-only)
              CustomInputField(
                controller: _userController,
                labelText: 'User',
                hintText: 'User name',
                prefixIcon: Icons.person_outline,
                enabled: false,
              ),
              const SizedBox(height: 20),

              // Date field
              InkWell(
                onTap: TimerService.instance.isRunning
                    ? null
                    : () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: TimerService.instance.isRunning
                        ? customColors.cardBackground!.withOpacity(0.5)
                        : customColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: customColors.inputBorder!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          196,
                          196,
                          196,
                        ).withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: customColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                color: customColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : DateFormat(
                                      'dd-MM-yyyy',
                                    ).format(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? customColors.textHint
                                    : customColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Start Time and End Time Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: TimerService.instance.isRunning
                          ? null
                          : () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: TimerService.instance.isRunning
                              ? customColors.cardBackground!.withOpacity(0.5)
                              : customColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: customColors.inputBorder!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: customColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Time',
                                    style: TextStyle(
                                      color: customColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _startTimeController.text.isEmpty
                                        ? 'hh:mm'
                                        : _startTimeController.text,
                                    style: TextStyle(
                                      color: _startTimeController.text.isEmpty
                                          ? customColors.textHint
                                          : customColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: TimerService.instance.isRunning
                          ? null
                          : () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: TimerService.instance.isRunning
                              ? customColors.cardBackground!.withOpacity(0.5)
                              : customColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: customColors.inputBorder!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: customColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Time',
                                    style: TextStyle(
                                      color: customColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _endTimeController.text.isEmpty
                                        ? 'hh:mm'
                                        : _endTimeController.text,
                                    style: TextStyle(
                                      color: _endTimeController.text.isEmpty
                                          ? customColors.textHint
                                          : customColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Type field
              DropdownButtonFormField<String>(
                value: _selectedType,

                hint: Text(
                  'Type',
                  style: TextStyle(color: customColors.textHint),
                ),
                style: TextStyle(
                  color: TimerService.instance.isRunning
                      ? customColors.textPrimary!.withValues(alpha: 0.5)
                      : customColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: customColors.cardBackground,
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: TextStyle(
                    color: customColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: customColors.cardBackground,
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    color: customColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: customColors.inputBorder!,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: customColors.inputBorder!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                items: _typeOptions.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: TimerService.instance.isRunning
                    ? null
                    : (value) {
                        setState(() => _selectedType = value!);
                      },
              ),
              const SizedBox(height: 20),
              // Note field
              CustomInputField(
                controller: _noteController,
                labelText: 'Note',
                hintText: 'Add notes...',
                isMultiline: true,
                maxLines: 4,
                minLines: 4,
                maxLength: 700,
                prefixIcon: Icons.description_outlined,
                enabled: TimerService.instance.isRunning ? false : true,
              ),
              const SizedBox(height: 8),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListenableBuilder(
                        listenable: TimerService.instance,
                        builder: (context, _) {
                          return ElevatedButton(
  onPressed: (TimerService.instance.isRunning || _isAddDisabled())
      ? null
      : (widget.editingEntry != null
            ? _saveAllEntries
            : _addTimeEntry),
  style: ElevatedButton.styleFrom(
    backgroundColor: customColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    elevation: 0,
  ),
  child: Text(
    widget.editingEntry != null ? 'SAVE' : 'ADD',
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),
);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(), // onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: customColors.error,
                        side: BorderSide(color: customColors.error!, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: (TimerService.instance.isRunning || _isSubmitDisabled())
                      ? null
                      : (widget.editingEntry != null
                            ? _saveAllEntries
                            : _saveAllEntries), //add time entries save funciton here as _addTimeEntry or with any other name
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.editingEntry != null ? 'SAVE' : 'SUBMIT ENTRIES',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              if (_entries.isNotEmpty) ...[
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: customColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: customColors.inputBorder!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${DateFormat('dd-MM-yyyy').format(entry.date)}",
                                style: TextStyle(
                                  color: customColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${entry.startTime} - ${entry.endTime}",
                                style: TextStyle(color: customColors.textSecondary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.type,
                                style: TextStyle(color: customColors.primary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _entries.removeAt(index);
                            });
                          },
                          icon: Icon(Icons.delete, color: customColors.error),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }
}
