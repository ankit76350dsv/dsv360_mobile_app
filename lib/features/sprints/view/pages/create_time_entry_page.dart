import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/features/sprints/model/task_model.dart';
import 'package:dsv360/features/sprints/viewmodel/timer_viewmodel.dart';
import 'package:dsv360/core/widgets/TopBar.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CreateTimeEntryPage extends ConsumerStatefulWidget {
  final TaskModel task;
  final String projectId;
  final String projectName;
  final String storyId;
  final String sprintId;
  final String? sourceType;
  final String? subTaskId;

  const CreateTimeEntryPage({
    super.key,
    required this.task,
    required this.projectId,
    required this.projectName,
    required this.storyId,
    required this.sprintId,
    this.sourceType,
    this.subTaskId,
  });

  @override
  ConsumerState<CreateTimeEntryPage> createState() =>
      _CreateTimeEntryPageState();
}

class _CreateTimeEntryPageState extends ConsumerState<CreateTimeEntryPage> {
  static const String _loadingKey = 'create_time_entry';

  final TextEditingController _noteController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _type = 'Non-Billable';

  static const List<String> _typeOptions = ['Billable', 'Non-Billable'];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // API expects "h:mm AM/PM"
  String _timeForApi(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  int _totalMinutes() {
    if (_startTime == null || _endTime == null) return 0;
    final startMins = _startTime!.hour * 60 + _startTime!.minute;
    final endMins = _endTime!.hour * 60 + _endTime!.minute;
    final diff = endMins - startMins;
    return diff < 0 ? 0 : diff;
  }

  // ── Pickers ──────────────────────────────────────────────────────────────

  Future<void> _pickDate(
    BuildContext context,
    CustomColors customColors,
  ) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: DateTime(2020),
      lastDate: today, // cannot pick tomorrow or later
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: customColors.primary!,
            onPrimary: Colors.white,
            surface: customColors.cardBackground!,
            onSurface: customColors.textPrimary!,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: customColors.cardBackground!,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(
    BuildContext context,
    CustomColors customColors,
    bool isStart,
  ) async {
    final initial = isStart
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ?? TimeOfDay.now());

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: customColors.primary!,
            onPrimary: Colors.white,
            surface: customColors.cardBackground!,
            onSurface: customColors.textPrimary!,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: customColors.cardBackground!,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // ── Validation & Submit ──────────────────────────────────────────────────

  void _showSnack(String msg) {
    showErrorSnackBar(context, msg);
  }

  Future<void> _submit() async {
    if (_selectedDate == null) {
      _showSnack('Please select a date');
      return;
    }
    if (_startTime == null) {
      _showSnack('Please select start time');
      return;
    }
    if (_endTime == null) {
      _showSnack('Please select end time');
      return;
    }
    final mins = _totalMinutes();
    if (mins <= 0) {
      _showSnack('End time must be after start time');
      return;
    }
    if (_noteController.text.trim().isEmpty) {
      _showSnack('Please enter a note');
      return;
    }

    final user = AuthManager.instance.currentUser;
    final userId = user?.id.toString() ?? '';
    final username = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    final notifier = ref.read(submitLoadingProvider(_loadingKey).notifier);
    notifier.state = true;

    try {
      await ref
          .read(createTimeEntryRepositoryProvider)
          .createTimeEntry(
            taskId: widget.task.id,
            taskName: widget.task.title,
            storyId: widget.storyId,
            sprintId: widget.sprintId,
            projectId: widget.projectId,
            projectName: widget.projectName,
            userId: userId,
            username: username,
            entryDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
            startTime: _timeForApi(_startTime!),
            endTime: _timeForApi(_endTime!),
            totalMinutes: mins,
            type: _type,
            note: _noteController.text.trim(),
            sourceType: widget.sourceType ?? 'SPRINT_TASK',
            subTaskId: widget.subTaskId,
          );

      if (!mounted) return;
      showSuccessSnackBar(context, 'Time entry saved successfully');
      Navigator.pop(context, true); // true = refresh needed
    } catch (e) {
      if (!mounted) return;
      _showSnack('Time Entry Overlapped - Failed to Save');
    } finally {
      notifier.state = false;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final textPrimary = customColors.textPrimary ?? Colors.black;
    final textSecondary = customColors.textSecondary ?? Colors.grey;
    final greyBorder = customColors.greyBorder ?? Colors.grey.shade300;
    final inputFill = customColors.inputFill ?? Colors.grey.shade50;
    final inputBorder = customColors.inputBorder ?? Colors.grey.shade300;
    final primary = customColors.primary ?? const Color(0xFF1A56DB);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ────────────────────────────────────────────────
            
              
              TopBar(
                title: 'Log Time',
                onBack: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
           
        
            // ── Task info pill ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.task_alt_outlined, color: primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.task.title,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        
            // ── Form ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Date picker ──────────────────────────────────
                    _FieldLabel(label: 'Date *', textSecondary: textSecondary),
                    const SizedBox(height: 6),
                    _PickerTile(
                      icon: Icons.calendar_today_outlined,
                      placeholder: 'Select date',
                      value: _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : null,
                      inputFill: inputFill,
                      inputBorder: inputBorder,
                      greyBorder: greyBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      primary: primary,
                      onTap: () => _pickDate(context, customColors),
                    ),
                    const SizedBox(height: 16),
        
                    // ── Start / End time row ─────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(
                                label: 'Start Time *',
                                textSecondary: textSecondary,
                              ),
                              const SizedBox(height: 6),
                              _PickerTile(
                                icon: Icons.access_time_outlined,
                                placeholder: 'Select',
                                value: _startTime != null
                                    ? _formatTime(_startTime!)
                                    : null,
                                inputFill: inputFill,
                                inputBorder: inputBorder,
                                greyBorder: greyBorder,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                primary: primary,
                                onTap: () =>
                                    _pickTime(context, customColors, true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(
                                label: 'End Time *',
                                textSecondary: textSecondary,
                              ),
                              const SizedBox(height: 6),
                              _PickerTile(
                                icon: Icons.access_time_filled_outlined,
                                placeholder: 'Select',
                                value: _endTime != null
                                    ? _formatTime(_endTime!)
                                    : null,
                                inputFill: inputFill,
                                inputBorder: inputBorder,
                                greyBorder: greyBorder,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                primary: primary,
                                onTap: () =>
                                    _pickTime(context, customColors, false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        
                    // duration preview
                    if (_startTime != null && _endTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: () {
                          final mins = _totalMinutes();
                          final h = mins ~/ 60;
                          final m = mins % 60;
                          final label = mins <= 0
                              ? 'End time must be after start time'
                              : 'Duration: ${h > 0 ? '${h}h ' : ''}${m}m';
                          return Text(
                            label,
                            style: TextStyle(
                              color: mins <= 0
                                  ? customColors.error ?? Colors.red
                                  : textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }(),
                      ),
        
                    const SizedBox(height: 16),
        
                    // ── Type selector ───────────────────────────────
                    CustomDropDownField(
                      hintText: 'Type',
                      labelText: 'Type *',
                      prefixIcon: Icons.category_outlined,
                      options: _typeOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                      selectedOption: _type,
                      onChanged: (value) {
                        if (value != null) setState(() => _type = value);
                      },
                    ),
                    const SizedBox(height: 16),
        
                    // ── Note ────────────────────────────────────────
                    _FieldLabel(label: 'Note *', textSecondary: textSecondary),
                    const SizedBox(height: 6),
                    CustomInputField(
                      controller: _noteController,
                      hintText: 'Add a note...',
                      isMultiline: true,
                      maxLines: 4,
                      minLines: 3,
                    ),
                   
        
                   
        
                    const SizedBox(height: 32),
        
                    // ── Buttons ──────────────────────────────────────
                    BottomTwoButtons(
                      loadingKey: _loadingKey,
                      button1Text: 'Cancel',
                      button2Text: 'Save Entry',
                      button1Function: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      button2Function: _submit,
                    ),
        
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final Color textSecondary;

  const _FieldLabel({required this.label, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── Picker tile (date / time) ─────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final String? value;
  final Color inputFill;
  final Color inputBorder;
  final Color greyBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.placeholder,
    required this.value,
    required this.inputFill,
    required this.inputBorder,
    required this.greyBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue ? primary.withValues(alpha: 0.5) : inputBorder,
            width: hasValue ? 1.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: hasValue ? primary : textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  color: hasValue ? textPrimary : textSecondary,
                  fontSize: 14,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
