import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/time_entry_model.dart';
import '../../core/constants/theme.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/TopBar.dart';
import 'time_entries_screen.dart';

class AddTimeEntryDialog extends StatefulWidget {
  final String taskId;
  final String taskName;
  final String currentUser;
  final TimeEntry? editingEntry; // For editing existing entry

  const AddTimeEntryDialog({
    super.key,
    required this.taskId,
    required this.taskName,
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

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController(text: widget.currentUser);
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
      _userController.text = entry.user;
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
    final customColors = Theme.of(context).custom;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
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
      final time = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
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

  void _addTimeEntry(BuildContext context) {
    final customColors = Theme.of(context).custom;
    if (_startTimeController.text.isEmpty || _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in start and end time'),
          backgroundColor: customColors.error,
        ),
      );
      return;
    }

    // If editing, update the entry and close dialog
    if (widget.editingEntry != null) {
      final updatedEntry = TimeEntry(
        id: widget.editingEntry!.id,
        user: _userController.text,
        date: _selectedDate ?? DateTime.now(),
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        type: _selectedType ?? 'Non-Billable',
        note: _noteController.text,
      );
      Navigator.pop(context, updatedEntry);
      return;
    }

    // Otherwise, add new entry to list
    final timeEntry = TimeEntry(
      id: 'TE${DateTime.now().millisecondsSinceEpoch % 1000}',
      user: _userController.text,
      date: _selectedDate ?? DateTime.now(),
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      type: _selectedType ?? 'Non-Billable',
      note: _noteController.text,
    );

    setState(() {
      _timeEntries.add(timeEntry);
      _startTimeController.clear();
      _endTimeController.clear();
      _noteController.clear();
      _startTime = null;
      _endTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Time entry added'),
        backgroundColor: customColors.primary,
      ),
    );
  }

  void _deleteTimeEntry(int index) {
    setState(() {
      _timeEntries.removeAt(index);
    });
  }

  void _submitTimeEntries() {
    final customColors = Theme.of(context).custom;
    if (_timeEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one time entry'),
          backgroundColor: customColors.error,
        ),
      );
      return;
    }

    Navigator.pop(context, _timeEntries);
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Scaffold(
      backgroundColor: customColors.background,
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
                    color: customColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: customColors.inputBorder!, width: 1.5),
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
                      Icon(Icons.calendar_today_outlined, color: customColors.textSecondary, size: 20),
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
                                  : DateFormat('dd-MM-yyyy').format(_selectedDate!),
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
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: customColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: customColors.inputBorder!, width: 1.5),
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
                            Icon(Icons.access_time_outlined, color: customColors.textSecondary, size: 20),
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
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: customColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: customColors.inputBorder!, width: 1.5),
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
                            Icon(Icons.access_time_outlined, color: customColors.textSecondary, size: 20),
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
                  color: customColors.textPrimary,
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
                  prefixIcon: Icon(Icons.category_outlined, color: customColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: customColors.inputBorder!, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: customColors.inputBorder!, width: 1.5),
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
                      child: ElevatedButton(
                        onPressed: () => _addTimeEntry(context),
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
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
              const SizedBox(height: 24),

              // Time entries list
              if (_timeEntries.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time Entries (${_timeEntries.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: customColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeEntriesScreen(
                              taskId: widget.taskId,
                              taskName: widget.taskName,
                              timeEntries: _timeEntries,
                            ),
                          ),
                        );
                      },
                      label: const Text('View All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customColors.primary,
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
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitTimeEntries,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
