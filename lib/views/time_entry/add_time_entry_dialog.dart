import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../models/time_entry_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/auth_manager.dart';
import '../../repositories/time_entry_repository.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/TopBar.dart';
import 'time_entries_screen.dart';

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
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<TimeEntry> _timeEntries = [];
  late TimeEntryRepository _repository;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = TimeEntryRepository();
    final firstName = AuthManager.instance.currentUser?.firstName ?? '';
    final lastName = AuthManager.instance.currentUser?.lastName ?? '';
    final loggedInUser = '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : widget.currentUser;
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
  }

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
      debugPrint('🔍 Fetching existing time entries for project: ${widget.projectId}');
      await _repository.getTimeEntriesByProject(widget.projectId);
    } catch (e) {
      debugPrint('❌ Error fetching time entries (this is just for debugging): $e');
    }
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
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.cardBackground,
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      // Validate that the selected date is within the last 7 days
      if (pickedDate.isBefore(sevenDaysAgo) || pickedDate.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only add time entries for the last 7 days'),
            backgroundColor: AppColors.error,
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

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.cardBackground,
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      final time = _timeOfDayToAMPM(pickedTime);
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
          _startTimeController.text = time;
        } else {
          _endTime = pickedTime;
          _endTimeController.text = time;
        }
      });
    }
  }

  Future<void> _addTimeEntry() async {
    if (_startTimeController.text.isEmpty || _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in start and end time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate that end time is after start time
    try {
      final format = DateFormat('h:mm a');
      final startTime = format.parse(_startTimeController.text);
      final endTime = format.parse(_endTimeController.text);

      if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid time format'),
          backgroundColor: AppColors.error,
        ),
      );
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time entry updated'),
            backgroundColor: AppColors.primary,
          ),
        );
      } catch (e) {
        debugPrint('❌ Error updating entry: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.error,
          ),
        );
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
        projectId: widget.projectId,
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
        _startTime = null;
        _endTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time entry created'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error creating entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deleteTimeEntry(int index) {
    setState(() {
      _timeEntries.removeAt(index);
    });
  }

  Future<void> _submitTimeEntries() async {
    if (_timeEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one time entry'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      final userId = AuthManager.instance.currentUser?.id ?? '';
      if (userId.isEmpty) {
        throw Exception('User ID not found');
      }

      debugPrint('📤 Submitting ${_timeEntries.length} time entries...');

      // Submit each time entry to API
      List<TimeEntry> submittedEntries = [];
      for (final entry in _timeEntries) {
        final createdEntry = await _repository.createTimeEntry(
          taskId: widget.taskId,
          projectId: widget.projectId,
          userId: userId,
          username: _userController.text,
          taskName: widget.taskName,
          projectName: widget.projectName,
          date: entry.date,
          startTime: entry.startTime,
          endTime: entry.endTime,
          description: entry.note,
          type: entry.type,
        );
        submittedEntries.add(createdEntry);
      }

      debugPrint('✅ All time entries submitted successfully');
      
      // Refresh the list to show newly added entries
      await _fetchExistingTimeEntries();
      
      // Clear the form
      setState(() {
        _timeEntries.clear();
        _startTimeController.clear();
        _endTimeController.clear();
        _noteController.clear();
      });
      
      Navigator.pop(context, submittedEntries);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${submittedEntries.length} time entries submitted'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error submitting entries: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: TopBar(
            title: '${widget.taskName} - Time Entries',
            onBack: () => Navigator.of(context).pop(),
            onInfoTap: () {},
          ),
        ),
      ),
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
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inputBorder, width: 1.5),
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
                      const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : DateFormat('dd-MM-yyyy').format(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? colors.tertiary.withOpacity(0.5)
                                    : colors.tertiary,
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
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.inputBorder, width: 1.5),
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
                            const Icon(Icons.access_time_outlined, color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Start Time',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
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
                                          ? colors.tertiary.withOpacity(0.5)
                                          : colors.tertiary,
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
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.inputBorder, width: 1.5),
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
                            const Icon(Icons.access_time_outlined, color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'End Time',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
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
                                          ? colors.tertiary.withOpacity(0.5)
                                          : colors.tertiary,
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
                  style: TextStyle(color: colors.tertiary.withOpacity(0.5)),
                ),
                style: TextStyle(
                  color: colors.tertiary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: colors.secondary,
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: colors.secondary,
                  prefixIcon: const Icon(Icons.category_outlined, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                items: _typeOptions.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value);
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
                            ? AppColors.error
                            : AppColors.textSecondary,
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
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addTimeEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.editingEntry != null ? 'SAVE' : 'ADD',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error, width: 2),
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
              const SizedBox(height: 24),

              // View All button - Always visible
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_timeEntries.isNotEmpty)
                    Text(
                      'Time Entries (${_timeEntries.length})',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    )
                  else
                    const Spacer(),
                  ElevatedButton.icon(
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
                    label: const Text('View All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
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
                        color: AppColors.cardBackground,
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
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${DateFormat('dd/MM/yy').format(entry.date)} • ${entry.type}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteTimeEntry(index),
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.error,
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
      ),
    );
  }
}
