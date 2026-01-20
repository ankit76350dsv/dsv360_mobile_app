import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/task_model.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_popup_dropdown.dart';

class AddTaskDialog extends StatefulWidget {
  final TaskModel? task; // For edit mode
  final String projectId;

  const AddTaskDialog({
    super.key,
    this.task,
    required this.projectId,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedStatus;
  String? _selectedAssignTo;
  String? _selectedProject;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _attachments = [];

  final List<String> _statusOptions = ['Pending', 'In Progress', 'Completed', 'On Hold'];
  final List<String> _projectOptions = [
    'Mobile App',
    'Web Portal',
    'Backend API',
    'Data Analytics',
    'Cloud Migration',
  ];
  final List<String> _assignToOptions = [
    'Ujjwal Mishra',
    'John Doe',
    'Jane Smith',
    'Mike Johnson',
    'Sarah Lee',
    'Bob Wilson',
    'Alice Brown'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _taskNameController.text = widget.task!.taskName;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedStatus = widget.task!.status;
      _selectedAssignTo = widget.task!.assignedTo;
      _startDate = widget.task!.startDate;
      _endDate = widget.task!.endDate;
      _attachments.addAll(widget.task!.attachments);
    } else {
      _selectedProject = _projectOptions[0];
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleAddAttachment() {
    // TODO: Implement file picker
    setState(() {
      _attachments.add('attachment_${_attachments.length + 1}.pdf');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attachment added'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedStatus == null) {
        _showError('Please select a status');
        return;
      }
      if (_startDate == null) {
        _showError('Please select a start date');
        return;
      }
      if (_endDate == null) {
        _showError('Please select an end date');
        return;
      }

      final taskId = widget.task?.id ?? 'T${DateTime.now().millisecondsSinceEpoch % 1000}';

      final task = TaskModel(
        id: taskId,
        taskName: _taskNameController.text.trim(),
        status: _selectedStatus!,
        projectId: widget.projectId,
        startDate: _startDate!,
        endDate: _endDate!,
        assignedTo: _selectedAssignTo,
        owner: _selectedAssignTo,
        description: _descriptionController.text.trim(),
        progress: widget.task?.progress ?? 0,
        attachments: List.from(_attachments),
        subTasksCount: widget.task?.subTasksCount ?? 0,
        timeEntriesCount: widget.task?.timeEntriesCount ?? 0,
      );

      Navigator.of(context).pop(task);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add New Task' : 'Edit Task'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Dropdown
                CustomPopupDropdown(
                  value: _selectedProject,
                  hint: 'Project',
                  items: _projectOptions,
                  icon: Icons.folder_outlined,
                  onChanged: (value) => setState(() => _selectedProject = value),
                ),
                const SizedBox(height: 20),

                // Task Name
                CustomInputField(
                  controller: _taskNameController,
                  hintText: 'Task Name',
                  labelText: 'Task Name',
                  prefixIcon: Icons.task_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter task name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Status Dropdown
                CustomPopupDropdown(
                  value: _selectedStatus,
                  hint: 'Status',
                  items: _statusOptions,
                  icon: Icons.assignment_outlined,
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
                const SizedBox(height: 20),

                // Start Date and End Date Row
                Row(
                  children: [
                    // Start Date
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.inputBorder,
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
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _startDate == null
                                      ? 'Start Date'
                                      : DateFormat('dd-MM-yyyy').format(_startDate!),
                                  style: TextStyle(
                                    color: _startDate == null
                                        ? AppColors.textHint
                                        : AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // End Date
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.inputBorder,
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
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _endDate == null
                                      ? 'End Date'
                                      : DateFormat('dd-MM-yyyy').format(_endDate!),
                                  style: TextStyle(
                                    color: _endDate == null
                                        ? AppColors.textHint
                                        : AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
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

                // Assign To Dropdown
                CustomPopupDropdown(
                  value: _selectedAssignTo,
                  hint: 'Assign To',
                  items: _assignToOptions,
                  icon: Icons.person_outline,
                  onChanged: (value) => setState(() => _selectedAssignTo = value),
                ),
                const SizedBox(height: 20),

                // Description
                CustomInputField(
                  controller: _descriptionController,
                  hintText: 'Description',
                  labelText: 'Task Description',
                  prefixIcon: Icons.description_outlined,
                  isMultiline: true,
                  maxLines: 4,
                  minLines: 4,
                ),
                const SizedBox(height: 24),

                // Attachments
                if (_attachments.isNotEmpty) ...[
                  Text(
                    'Attachments',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attachments.asMap().entries.map((entry) {
                      return Chip(
                        label: Text(
                          entry.value,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        backgroundColor: AppColors.inputFill,
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onDeleted: () {
                          setState(() {
                            _attachments.removeAt(entry.key);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Add Attachment Button
                OutlinedButton.icon(
                  onPressed: _handleAddAttachment,
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text('ATTACHMENT', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'ADD',
                            style: TextStyle(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
