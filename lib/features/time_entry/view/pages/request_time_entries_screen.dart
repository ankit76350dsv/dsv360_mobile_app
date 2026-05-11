import 'dart:convert';

import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/cache/user_cache_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/features/time_entry/model/time_entry_model.dart';
import 'package:dsv360/features/time_entry/repositories/request_entry_repository.dart';
import 'package:dsv360/features/time_entry/view/pages/time_entry_history.dart';
import 'package:dsv360/features/time_entry/view/pages/timer_service.dart';
import 'package:dsv360/core/widgets/TopBar.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class RequestTimeEntriesScreen extends ConsumerStatefulWidget {
  final String currentUser;
  final TimeEntry? editingEntry;
  final String projectId;
  final String projectName;
  final String taskId;
  final String taskName;

  const RequestTimeEntriesScreen({
    super.key,
    this.editingEntry,
    required this.currentUser,
    required this.projectId,
    required this.projectName,
    required this.taskId,
    required this.taskName,
  });

  @override
  ConsumerState<RequestTimeEntriesScreen> createState() =>
      _RequestTimeEntriesScreenState();
}

class _RequestTimeEntriesScreenState extends ConsumerState<RequestTimeEntriesScreen> {
  late TextEditingController _userController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _noteController;

  late TextEditingController _projectIdController;
  late TextEditingController _projectNameController;
  late TextEditingController _taskIdController;
  late TextEditingController _taskNameController;

  late String _selectedType;
  bool _isLoading = false;

  final List<String> _typeOptions = ['Billable', 'Non-Billable'];

  DateTime? _selectedDate;

  final List<TimeEntry> _entries = [];

  final RequestEntryRepository _repository = RequestEntryRepository();

  // FIX: single listener attached to all controllers so _isAddDisabled() re-evaluates on every change
  void _onFieldChanged() => setState(() {});

  bool _isSubmitDisabled() {
    final isFormDirty =
        _startTimeController.text.isNotEmpty ||
        _endTimeController.text.isNotEmpty ||
        _noteController.text.isNotEmpty;
    if (isFormDirty) return true;
    if (_entries.isEmpty) return true;
    return false;
  }

  bool _isAddDisabled() {
    return _startTimeController.text.isEmpty ||
        _noteController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _endTimeController.text.isEmpty;
  }

  @override
  void initState() {
    super.initState();

    final cached = ref.read(globalUserProvider);
    final firstName = AuthManager.instance.currentUser?.firstName ?? cached?.firstName ?? '';
    final lastName = AuthManager.instance.currentUser?.lastName ?? cached?.lastName ?? '';
    final loggedInUser = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : widget.currentUser;

    _userController = TextEditingController(text: loggedInUser);
    _dateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _noteController = TextEditingController();

    _projectIdController = TextEditingController(text: widget.projectId);
    _projectNameController = TextEditingController(text: widget.projectName);
    _taskIdController = TextEditingController(text: widget.taskId);
    _taskNameController = TextEditingController(text: widget.taskName);

    _selectedType = 'Non-Billable';

    // FIX: attach listeners so every field change triggers setState and _isAddDisabled() re-evaluates immediately
    _startTimeController.addListener(_onFieldChanged);
    _endTimeController.addListener(_onFieldChanged);
    _noteController.addListener(_onFieldChanged);
    _dateController.addListener(_onFieldChanged);

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

  int _convertToMinutes(String time) {
    final parts = time.split(' ');
    final timePart = parts[0];
    final period = parts[1];
    final hourMinute = timePart.split(':');
    int hour = int.parse(hourMinute[0]);
    final int minute = int.parse(hourMinute[1]);
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return hour * 60 + minute;
  }

  void _addTimeEntry() {
    if (_selectedDate == null ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      showErrorSnackBar(context, 'Please fill all required fields');
      return;
    }

    final newStart = _convertToMinutes(_startTimeController.text);
    final newEnd = _convertToMinutes(_endTimeController.text);

    if (newEnd <= newStart) {
      showErrorSnackBar(context, 'End time must be after start time');
      return;
    }

    for (final entry in _entries) {
      if (DateFormat('dd-MM-yyyy').format(entry.date) ==
          DateFormat('dd-MM-yyyy').format(_selectedDate!)) {
        final existingStart = _convertToMinutes(entry.startTime);
        final existingEnd = _convertToMinutes(entry.endTime);
        final isOverlapping = newStart < existingEnd && newEnd > existingStart;
        if (isOverlapping) {
          showErrorSnackBar(context, 'Time overlaps with an existing entry');
          return;
        }
      }
    }

    // Resolve username for the entry
    final cachedU = ref.read(globalUserProvider);
    final firstName = AuthManager.instance.currentUser?.firstName ?? cachedU?.firstName ?? '';
    final lastName = AuthManager.instance.currentUser?.lastName ?? cachedU?.lastName ?? '';
    final username = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : widget.currentUser;

    // FIX: TimeEntry requires id and user — supply them correctly
    final newEntry = TimeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // temp local id
      user: username,
      date: _selectedDate!,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      note: _noteController.text,
      type: _selectedType,
    );

    setState(() {
      _entries.add(newEntry);
      _startTimeController.clear();
      _endTimeController.clear();
      _noteController.clear();
      _selectedType = 'Non-Billable';
    });

    showSuccessSnackBar(context, 'Entry added (${_entries.length} total)');
  }

  void _saveAllEntries() async {
    if (_entries.isEmpty) {
      showErrorSnackBar(context, 'Add at least one entry');
      return;
    }

    setState(() => _isLoading = true);

    final cachedUser = ref.read(globalUserProvider);
    final userId = AuthManager.instance.currentUser?.id ?? cachedUser?.id ?? '';
    final firstName = AuthManager.instance.currentUser?.firstName ?? cachedUser?.firstName ?? '';
    final lastName = AuthManager.instance.currentUser?.lastName ?? cachedUser?.lastName ?? '';
    final username = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : widget.currentUser;

    final List<Map<String, dynamic>> jsonEntries = _entries.map((entry) {
      final start = _convertToMinutes(entry.startTime);
      final end = _convertToMinutes(entry.endTime);
      return {
        'Username': username,
        'User_ID': userId,
        'Entry_Date': DateFormat('yyyy-MM-dd').format(entry.date),
        'Note': entry.note,
        'Type': entry.type,
        'Start_time': entry.startTime,
        'End_time': entry.endTime,
        'Total_time': end - start,
        'Task_ID': _taskIdController.text,
        'Task_Name': _taskNameController.text,
        'Project_ID': _projectIdController.text,
        'Project_Name': _projectNameController.text,
      };
    }).toList();

    final String timeentryDataString = jsonEncode(jsonEntries);

    debugPrint('📤 Submitting entries: $timeentryDataString');

    try {
      // FIX: call createRequestEntry (named params) — the method that actually
      //      exists on the repository, not the missing createRequestEntryFromMap
      final response = await _repository.createRequestEntry(
        projectId: _projectIdController.text,
        projectName: _projectNameController.text,
        taskId: _taskIdController.text,
        taskName: _taskNameController.text,
        timeentryData: timeentryDataString,
        userId: userId,
        username: username,
      );

      final bool isSuccess = response['success'] == true;
      final String message =
          response['message']?.toString() ?? 'Something went wrong';

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (isSuccess) {
        setState(() {
          _entries.clear();
        });

        showSuccessSnackBar(context, message);

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        showErrorSnackBar(context, message); // backend message shown
      }
    } catch (e) {
      debugPrint('❌ Submission failed: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorSnackBar(context, 'Submission failed. Please try again.');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final customColors = Theme.of(context).custom;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime cutoffDate = today.subtract(const Duration(days: 7));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: cutoffDate,
      firstDate: DateTime(2000),
      lastDate: cutoffDate,
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
      if (pickedDate.isAfter(today)) {
        showErrorSnackBar(
          context,
          'You can only add time entries for the last 7 days',
        );
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

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
  void dispose() {
    // FIX: remove listeners before disposing to avoid memory leaks
    _startTimeController.removeListener(_onFieldChanged);
    _endTimeController.removeListener(_onFieldChanged);
    _noteController.removeListener(_onFieldChanged);
    _dateController.removeListener(_onFieldChanged);

    _userController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _noteController.dispose();
    _projectIdController.dispose();
    _projectNameController.dispose();
    _taskIdController.dispose();
    _taskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Scaffold(
      backgroundColor: customColors.background,

      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              TopBar(
                title: "${widget.taskName} - Request Entries",
                onBack: () => Navigator.of(context).pop(),
                actionIcon: Icons.history,

                onInfoTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimeEntryHistory()),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomInputField(
                      controller: _userController,
                      labelText: 'User',
                      hintText: 'User name',
                      prefixIcon: Icons.person_outline,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),

                    // Date picker
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

                    // Start / End time row
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
                                    ? customColors.cardBackground!.withOpacity(
                                        0.5,
                                      )
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color:
                                                _startTimeController
                                                    .text
                                                    .isEmpty
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
                                    ? customColors.cardBackground!.withOpacity(
                                        0.5,
                                      )
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color:
                                                _endTimeController.text.isEmpty
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

                    // Type dropdown
                    CustomDropDownField(
                      hintText: 'Type',
                      labelText: 'Type',
                      prefixIcon: Icons.category_outlined,
                      options: _typeOptions
                          .map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      selectedOption: _selectedType,
                      enabled: !TimerService.instance.isRunning,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
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

                    // ADD / CANCEL row
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
                                  onPressed:
                                      (TimerService.instance.isRunning ||
                                          _isAddDisabled())
                                      ? null
                                      : (widget.editingEntry != null
                                            ? _saveAllEntries
                                            : _addTimeEntry),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: customColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    widget.editingEntry != null
                                        ? 'SAVE'
                                        : 'ADD',
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
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: customColors.error,
                              side: BorderSide(
                                color: customColors.error!,
                                width: 2,
                              ),
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

                    // SUBMIT ENTRIES button
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed:
                            (TimerService.instance.isRunning ||
                                _isSubmitDisabled() ||
                                _isLoading)
                            ? null
                            : _saveAllEntries,
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
                                widget.editingEntry != null
                                    ? 'SAVE'
                                    : 'SUBMIT ENTRIES',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    // Queued entries list
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
                              border: Border.all(
                                color: customColors.inputBorder!,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat(
                                          'dd-MM-yyyy',
                                        ).format(entry.date),
                                        style: TextStyle(
                                          color: customColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${entry.startTime} - ${entry.endTime}',
                                        style: TextStyle(
                                          color: customColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        entry.type,
                                        style: TextStyle(
                                          color: customColors.primary,
                                        ),
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
                                  icon: Icon(
                                    Icons.delete,
                                    color: customColors.error,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
