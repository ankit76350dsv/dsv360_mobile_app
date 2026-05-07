import 'package:dsv360/features/time_entry/view/pages/request_time_entries_screen.dart' as req_screen;
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/time_entry_model.dart';
import '../../../../core/constants/theme.dart';
import '../../../../core/constants/auth_manager.dart';
import '../../repositories/time_entry_repository.dart';
import '../../repositories/start_timer_repository.dart';
import '../../../../core/widgets/custom_dropdown_field.dart';
import '../../../../core/widgets/custom_input_field.dart';
import '../../../../core/widgets/TopBar.dart';
import 'time_entries_screen.dart';
import 'timer_service.dart';
import 'running_timer_screen.dart';
import '../../repositories/check_timer_status_repository.dart';

class AddTimeEntryDialog extends StatefulWidget {
  final String taskId;
  final String projectId;
  final String taskName;
  final String projectName;
  final String currentUser;
  final TimeEntry? editingEntry; // For editing existing entry
  const AddTimeEntryDialog({
    super.key,
    required this.taskId,
    required this.projectId,
    required this.taskName,
    required this.projectName,
    required this.currentUser,
    this.editingEntry,
  });

  @override
  State<AddTimeEntryDialog> createState() => _AddTimeEntryDialogState();
}

class _AddTimeEntryDialogState extends State<AddTimeEntryDialog> {
  late TextEditingController _userController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _noteController;

  String? _selectedType;
  final List<String> _typeOptions = ['Billable', 'Non-Billable'];

  DateTime? _selectedDate;

  final isRunning = TimerService.instance.isRunning;

  final List<TimeEntry> _timeEntries = [];
  List<TimeEntry> _existingEntries = [];
  late TimeEntryRepository _repository;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = TimeEntryRepository();
    final firstName = AuthManager.instance.currentUser?.firstName ?? '';
    final lastName = AuthManager.instance.currentUser?.lastName ?? '';
    final loggedInUser = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : widget.currentUser;
    _userController = TextEditingController(text: loggedInUser);
    _dateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _noteController = TextEditingController();

    _selectedType = 'Non-Billable';
    _selectedDate = DateTime.now();

    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);

    // If editing, populate fields with existing entry data
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

    // Fetch existing time entries to see the structure
    _fetchExistingTimeEntries();
    // Sync timer state from server in case app was restarted while timer was running
    _syncTimerFromServer();
  }

  Future<void> _syncTimerFromServer() async {
    // Only sync if TimerService thinks it's not running — avoids duplicate tickers
    if (TimerService.instance.isRunning) return;
    try {
      final userId = AuthManager.instance.currentUser?.id ?? '';
      if (userId.isEmpty) return;
      final status = await CheckTimerStatusRepository().checkTimerStatus(
        userId,
      );
      final message = (status['message'] ?? '').toString().toLowerCase();
      final isRunning = message.contains('running') && !message.contains('not');
      if (isRunning) {
        final startTimeStr = (status['startTime'] ?? '').toString();
        final serverStart = DateTime.tryParse(
          startTimeStr.replaceFirst(' ', 'T'),
        );
        if (serverStart != null) {
          TimerService.instance.restoreFromServer(serverStart);
        }
      }
    } catch (e) {
      debugPrint('⏱️ Could not sync timer from server: $e');
    }
  }

  String get _projectIdForRequests => widget.projectId.trim();

  /// Convert TimeOfDay to 12-hour AM/PM format (e.g., "3:35 PM")
  String _timeOfDayToAMPM(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Calculate total time in minutes from AM/PM format times
  int _calculateTotalMinutes(String startTimeAMPM, String endTimeAMPM) {
    try {
      final format = DateFormat('h:mm a');
      final startTime = format.parse(startTimeAMPM);
      final endTime = format.parse(endTimeAMPM);

      Duration duration = endTime.difference(startTime);
      if (duration.isNegative) {
        // If end time is before start time, assume next day
        duration = Duration(hours: 24) + duration;
      }
      return duration.inMinutes;
    } catch (e) {
      debugPrint('❌ Error calculating total minutes: $e');
      return 0;
    }
  }

  Future<void> _fetchExistingTimeEntries() async {
    try {
      debugPrint(
        '🔍 Fetching existing time entries for project: ${widget.projectId}',
      );
      final entries = await _repository.getTimeEntriesByProject(
        widget.projectId,
      );
      setState(() {
        _existingEntries = entries;
      });
    } catch (e) {
      debugPrint(
        '❌ Error fetching time entries (this is just for debugging): $e',
      );
    }
  }

  bool _hasTimeOverlap(
    String newStart,
    String newEnd,
    DateTime newDate, {
    String? excludeEntryId,
  }) {
    try {
      final format = DateFormat('h:mm a');
      final newStartTime = format.parse(newStart);
      final newEndTime = format.parse(newEnd);

      final allEntries = [
        ..._existingEntries,
        ..._timeEntries,
      ].where((e) => e.id != excludeEntryId).toList();

      for (final entry in allEntries) {
        if (entry.date.year == newDate.year &&
            entry.date.month == newDate.month &&
            entry.date.day == newDate.day) {
          final entryStart = format.parse(entry.startTime);
          final entryEnd = format.parse(entry.endTime);
          if (newStartTime.isBefore(entryEnd) &&
              newEndTime.isAfter(entryStart)) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void _showOverlapSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Overlapping Time Entry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This entry overlaps with one already added. Tap "View All" to review your entries.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View All',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TimeEntriesScreen(
                  taskId: widget.taskId,
                  projectId: widget.projectId,
                  taskName: widget.taskName,
                  projectName: widget.projectName,
                  timeEntries: _timeEntries,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final customColors = Theme.of(context).custom;
    final DateTime today = DateTime.now();
    final DateTime sevenDaysAgo = today.subtract(const Duration(days: 6));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: sevenDaysAgo,
      lastDate: today,
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
      if (pickedDate.isBefore(sevenDaysAgo) || pickedDate.isAfter(today)) {
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

  Future<void> _addTimeEntry() async {
    final projectId = _projectIdForRequests;

    if (projectId.isEmpty) {
      showErrorSnackBar(
        context,
        'Project ID is missing. Please reopen the task.',
      );
      return;
    }

    if (_startTimeController.text.isEmpty || _endTimeController.text.isEmpty) {
      showErrorSnackBar(context, 'Please fill in start and end time');
      return;
    }

    // Validate that end time is after start time
    try {
      final format = DateFormat('h:mm a');
      final startTime = format.parse(_startTimeController.text);
      final endTime = format.parse(_endTimeController.text);

      if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
        showErrorSnackBar(context, 'End time must be after start time');
        return;
      }
    } catch (e) {
      showErrorSnackBar(context, 'Invalid time format');
      return;
    }

    // Check for overlapping entries
    final checkDate = _selectedDate ?? DateTime.now();
    final excludeId = widget.editingEntry?.id;
    if (_hasTimeOverlap(
      _startTimeController.text,
      _endTimeController.text,
      checkDate,
      excludeEntryId: excludeId,
    )) {
      _showOverlapSnackbar();
      return;
    }

    // If editing, update via API and close dialog
    if (widget.editingEntry != null) {
      try {
        setState(() => _isLoading = true);

        // Calculate total time in minutes
        final totalMinutes = _calculateTotalMinutes(
          _startTimeController.text,
          _endTimeController.text,
        );
        debugPrint('⏱️ Calculated total minutes: $totalMinutes');

        final updatedEntry = await _repository.updateTimeEntry(
          timeEntryId: widget.editingEntry!.id,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          date: _selectedDate,
          description: _noteController.text,
          totalMinutes: totalMinutes,
        );

        debugPrint('✅ Time entry updated successfully');
        Navigator.pop(context, updatedEntry);

        showSuccessSnackBar(context, 'Time entry updated');
      } catch (e) {
        debugPrint('❌ Error updating entry: $e');
        showErrorSnackBar(context, 'Time Entry is Already Added!');
      } finally {
        setState(() => _isLoading = false);
      }
      return;
    }

    // Create new entry via API immediately
    try {
      setState(() => _isLoading = true);

      final userId = AuthManager.instance.currentUser?.id ?? '';
      final firstName = AuthManager.instance.currentUser?.firstName ?? '';
      final lastName = AuthManager.instance.currentUser?.lastName ?? '';
      final username = '$firstName $lastName'.trim();
      if (userId.isEmpty || username.isEmpty) {
        throw Exception('User information not found');
      }

      // Calculate total time in minutes
      final totalMinutes = _calculateTotalMinutes(
        _startTimeController.text,
        _endTimeController.text,
      );
      debugPrint('⏱️ Calculated total minutes: $totalMinutes');

      final createdEntry = await _repository.createTimeEntry(
        taskId: widget.taskId,
        projectId: projectId,
        userId: userId,
        username: username,
        taskName: widget.taskName,
        projectName: widget.projectName,
        date: _selectedDate ?? DateTime.now(),
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        description: _noteController.text,
        type: _selectedType ?? 'Non-Billable',
        totalMinutes: totalMinutes,
      );

      debugPrint('✅ Time entry created successfully');

      // Add to local list for instant display
      setState(() {
        _timeEntries.add(createdEntry);
        _startTimeController.clear();
        _endTimeController.clear();
        _noteController.clear();
      });

      showSuccessSnackBar(context, 'Time entry created');
    } catch (e) {
      debugPrint('❌ Error creating entry: $e');
      showErrorSnackBar(context, 'Time Entry is Already Added!');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startServerTimer() async {
    final timer = TimerService.instance;
    final projectId = _projectIdForRequests;

    if (projectId.isEmpty) {
      showErrorSnackBar(context, 'Please Reopen Tasks and Try again');
      return;
    }

    if (timer.isRunning) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RunningTimerScreen(
            taskId: widget.taskId,
            projectId: widget.projectId,
            taskName: widget.taskName,
            projectName: widget.projectName,
          ),
        ),
      ).then((_) {
        // This runs when you pop back to the parent page
        // Call your data reload methods here
        _fetchExistingTimeEntries(); // or whatever method reloads your data
        _syncTimerFromServer();
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = AuthManager.instance.currentUser?.id ?? '';
      final firstName = AuthManager.instance.currentUser?.firstName ?? '';
      final lastName = AuthManager.instance.currentUser?.lastName ?? '';
      final username = '$firstName $lastName'.trim();

      await StartTimerRepository().startTimer(
        userId: userId,
        username: username,
        taskId: widget.taskId,
        taskName: widget.taskName,
        projectId: projectId,
        projectName: widget.projectName,
        entryDate: DateTime.now(),
      );

      timer.startLocal();
      await _fetchExistingTimeEntries();
      await _syncTimerFromServer();
    } catch (e) {
      debugPrint('❌ Error starting server timer: $e');
      if (mounted) {
        showErrorSnackBar(context, 'Failed to start timer. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _deleteTimeEntry(int index) {
    setState(() {
      _timeEntries.removeAt(index);
    });
  }

  // Future<void> _submitTimeEntries() async {
  //      final customColors = Theme.of(context).custom;
  //   if (_timeEntries.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('Please add at least one time entry'),
  //         backgroundColor: customColors.error,
  //       ),
  //     );
  //     return;
  //   }

  //   try {
  //     setState(() => _isLoading = true);

  //     final userId = AuthManager.instance.currentUser?.id ?? '';
  //     if (userId.isEmpty) {
  //       throw Exception('User ID not found');
  //     }

  //     debugPrint('📤 Submitting ${_timeEntries.length} time entries...');

  //     // Submit each time entry to API
  //     List<TimeEntry> submittedEntries = [];
  //     for (final entry in _timeEntries) {
  //       final createdEntry = await _repository.createTimeEntry(
  //         taskId: widget.taskId,
  //         projectId: widget.projectId,
  //         userId: userId,
  //         username: _userController.text,
  //         taskName: widget.taskName,
  //         projectName: widget.projectName,
  //         date: entry.date,
  //         startTime: entry.startTime,
  //         endTime: entry.endTime,
  //         description: entry.note,
  //         type: entry.type,
  //       );
  //       submittedEntries.add(createdEntry);
  //     }

  //     debugPrint('✅ All time entries submitted successfully');

  //     // Refresh the list to show newly added entries
  //     await _fetchExistingTimeEntries();

  //     // Clear the form
  //     setState(() {
  //       _timeEntries.clear();
  //       _startTimeController.clear();
  //       _endTimeController.clear();
  //       _noteController.clear();
  //     });

  //     Navigator.pop(context, submittedEntries);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('${submittedEntries.length} time entries submitted'),
  //         backgroundColor: customColors.primary,
  //       ),
  //     );
  //   } catch (e) {
  //     debugPrint('❌ Error submitting entries: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to submit: $e'),
  //         backgroundColor: customColors.error,
  //       ),
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Scaffold(
      backgroundColor: customColors.background,

      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(
                title: '${widget.taskName} - Time Entries',
                onBack: () => Navigator.of(context).pop(),
                actionIcon: Icons.timer_outlined,
                onInfoTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimeEntriesScreen(
                        taskId: widget.taskId,
                        projectId: widget.projectId,
                        taskName: widget.taskName,
                        projectName: widget.projectName,
                        timeEntries: _timeEntries,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
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
                              color: Colors.black.withOpacity(0.05),
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
                                                _startTimeController.text.isEmpty
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
                
                    // Character count display
                    Align(
                      alignment: Alignment.centerRight,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _noteController,
                        builder: (context, value, child) {
                          final remaining = 700 - value.text.length;
                          return Text(
                            '$remaining characters left',
                            style: TextStyle(
                              color: remaining < 100
                                  ? Colors.red
                                  : customColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: customColors.primary!.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListenableBuilder(
                              listenable: TimerService.instance,
                              builder: (context, _) {
                                return ElevatedButton(
                                  onPressed:
                                      (_isLoading ||
                                          TimerService.instance.isRunning)
                                      ? null
                                      : _addTimeEntry,
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
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
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
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
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
                
                    // Timer + Request row
                    Row(
                      children: [
                        Expanded(
                          child: ListenableBuilder(
                            listenable: TimerService.instance,
                            builder: (context, _) {
                              final timer = TimerService.instance;
                              final isRunning = timer.isRunning;
                              return ElevatedButton.icon(
                                onPressed: _isLoading ? null : _startServerTimer,
                                icon: Icon(
                                  isRunning ? Icons.stop : Icons.play_arrow,
                                  size: 18,
                                ),
                                label: Text(
                                  isRunning ? timer.elapsedFormatted : '00:00:00',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isRunning
                                      ? Colors.red
                                      : Colors.green[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                (_isLoading || TimerService.instance.isRunning)
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            req_screen.RequestTimeEntriesScreen(
                                              currentUser: widget.currentUser,
                                              projectId: widget.projectId,
                                              projectName: widget.projectName,
                                              taskId: widget.taskId,
                                              taskName: widget.taskName,
                                            ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.send_outlined, size: 18),
                            label: const Text(
                              'REQUEST',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).custom.textSecondary,
                              side: BorderSide(
                                color: Theme.of(context).custom.inputBorder!,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                
                    // View All button - Always visible
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_timeEntries.isNotEmpty)
                          Text(
                            'Time Entries (${_timeEntries.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: customColors.textPrimary,
                            ),
                          )
                        else
                          const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 12),
                
                    // Time entries list
                    if (_timeEntries.isNotEmpty) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _timeEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _timeEntries[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: customColors.cardBackground,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.startTime} - ${entry.endTime}',
                                        style: TextStyle(
                                          color: customColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${DateFormat('dd/MM/yy').format(entry.date)} • ${entry.type}',
                                        style: TextStyle(
                                          color: customColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _deleteTimeEntry(index),
                                  icon: Icon(
                                    Icons.delete,
                                    color: customColors.error,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
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
