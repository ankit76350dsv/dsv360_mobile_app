import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/badges/viewmodel/badge_image_viewmodel.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';

import 'package:dsv360/features/sprints/viewmodel/task_subtask_viewmodel.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends ConsumerStatefulWidget {
  final String projectId;
  final String storyId;
  final String? storyTitle;

  const AddTaskPage({
    super.key,
    required this.projectId,
    required this.storyId,
    this.storyTitle,
  });

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();

  final String _loadingKey = 'add_task_key';

  String? _selectedAssigneeId;
  String _selectedStatus = 'NOT_STARTED';
  DateTime? _dueDate;

  List<dynamic> _users = [];
  bool _isUsersLoading = false;
  bool _hasUsersError = false;

  static const List<Map<String, String>> _statusOptions = [
    {'label': 'Not Started', 'value': 'NOT_STARTED'},
    {'label': 'WIP', 'value': 'WIP'},
    {'label': 'Under Internal Testing', 'value': 'UNDER_INTERNAL_TESTING'},
    {'label': 'Pending Zoho', 'value': 'PENDING_FROM_ZOHO'},
    {'label': 'Pending Client', 'value': 'PENDING_FROM_CLIENT'},
    {'label': 'Released For UAT', 'value': 'RELEASED_FOR_UAT'},
    {'label': 'UAT Approved', 'value': 'UAT_APPROVED_BY_CLIENT'},
    {'label': 'Closed', 'value': 'CLOSED'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isUsersLoading = true;
      _hasUsersError = false;
    });
    try {
      _users =
          await ref.read(fetchBadgeUsersRepositoryProvider).fetchUsers();
    } catch (_) {
      _hasUsersError = true;
      _users = [];
    } finally {
      if (mounted) setState(() => _isUsersLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final customColors = Theme.of(context).custom;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: customColors.primary!,
              onPrimary: Colors.white,
              surface: customColors.cardBackground!,
              onSurface: customColors.textPrimary!,
            ),
            dialogTheme: DialogThemeData(
                backgroundColor: customColors.cardBackground!),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _createTask() async {
    if (_titleController.text.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter task title');
      return;
    }

    if (_selectedAssigneeId == null || _selectedAssigneeId!.isEmpty) {
      showErrorSnackBar(context, 'Please select assignee');
      return;
    }

    if (_dueDate == null) {
      showErrorSnackBar(context, 'Please select due date');
      return;
    }

    if (_hoursController.text.trim().isEmpty &&
        _minutesController.text.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter estimated time');
      return;
    }

    final submitLoadingNotifier =
        ref.read(submitLoadingProvider(_loadingKey).notifier);
    submitLoadingNotifier.state = true;

    try {
      final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
      final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

      if (minutes > 59) {
        showErrorSnackBar(context, 'Minutes must be between 0 and 59');
        submitLoadingNotifier.state = false;
        return;
      }

      final estimatedHours = hours + (minutes / 60.0);
      final formattedDate = DateFormat('yyyy-MM-dd').format(_dueDate!);

      final repo = ref.read(createTaskRepositoryProvider);

      await repo.createTask(
        title: _titleController.text.trim(),
        projectId: widget.projectId,
        storyId: widget.storyId,
        assigneeId: _selectedAssigneeId!,
        dueDate: formattedDate,
        estimatedHours: estimatedHours,
        status: _selectedStatus,
      );

      if (!mounted) return;

      showSuccessSnackBar(context, 'Task created successfully');

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

     
      final errorText = e.toString();
      debugPrint("error here");
      debugPrint(e.toString());
      final message = errorText.contains('do not have permission')
          ? 'Permission denied from server, please try again.'
          : 'Failed to create Task. Please try again.';

      
      showErrorSnackBar(context, message);
      
    } finally {
      submitLoadingNotifier.state = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).custom;

    final statusItems = _statusOptions
        .map((s) => DropdownMenuItem<String>(
              value: s['value']!,
              child: Text(s['label']!),
            ))
        .toList();

    final assigneeItems = [
      const DropdownMenuItem<String>(
        value: '',
        child: Text('Unassigned'),
      ),
      ..._users.map((u) => DropdownMenuItem<String>(
            value: u.userId,
            child: Text(u.fullName),
          )),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Task',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text(
                'Task Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Task Title
                      CustomInputField(
                        controller: _titleController,
                        hintText: 'Task Title',
                        labelText: 'Task Title *',
                        prefixIcon: Icons.check_circle_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter task title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Assignee
                      CustomDropDownField(
                        hintText: _isUsersLoading
                            ? 'Loading users...'
                            : _hasUsersError
                                ? 'Failed to load users'
                                : 'Select assignee',
                        labelText: 'Assignee *',
                        prefixIcon: Icons.person_outline,
                        searchable: true,
                        searchHintText: 'Search user',
                        options: assigneeItems,
                        selectedOption: _selectedAssigneeId ?? '',
                        onChanged: assigneeItems.isEmpty
                            ? (_) {}
                            : (val) {
                                setState(
                                  () => _selectedAssigneeId =
                                      val == '' ? null : val,
                                );
                              },
                      ),

                      const SizedBox(height: 20),

                      // Status
                      CustomDropDownField(
                        hintText: 'Select status',
                        labelText: 'Status',
                        prefixIcon: Icons.track_changes_outlined,
                        options: statusItems,
                        selectedOption: _selectedStatus,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Estimated Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Time *',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInputField(
                                  controller: _hoursController,
                                  hintText: 'Hours',
                                  labelText: 'Hours',
                                  prefixIcon: Icons.schedule_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if ((value == null || value.isEmpty) &&
                                        _minutesController.text.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        int.tryParse(value) == null) {
                                      return 'Numbers only';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomInputField(
                                  controller: _minutesController,
                                  hintText: 'Minutes',
                                  labelText: 'Minutes',
                                  prefixIcon: Icons.timer_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final mins = int.tryParse(value);
                                      if (mins == null) return 'Numbers only';
                                      if (mins > 59) return '0-59 only';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Due Date
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: customColors.inputFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: customColors.inputBorder!,
                              width: 1.5,
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
                              Icon(
                                Icons.calendar_today_outlined,
                                color: customColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _dueDate == null
                                      ? 'Due Date *'
                                      : DateFormat('dd-MM-yyyy').format(_dueDate!),
                                  style: TextStyle(
                                    color: _dueDate == null
                                        ? customColors.textHint
                                        : customColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      BottomTwoButtons(
                        loadingKey: _loadingKey,
                        button1Text: 'cancel',
                        button2Text: 'create task',
                        button1Function: () => Navigator.pop(context),
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            _createTask();
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
}
