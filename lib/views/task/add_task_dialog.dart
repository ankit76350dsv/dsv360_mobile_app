import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/task.dart';
import '../../models/employee.dart';
import '../../models/attachment.dart';
import '../../providers/project_provider.dart';
import '../../providers/employee_provider.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_popup_dropdown.dart';
import '../widgets/TopBar.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final Task? task; // For edit mode
  final String projectId;

  const AddTaskDialog({
    super.key,
    this.task,
    required this.projectId,
  });

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedStatus;
  List<Employee> _selectedAssignees = []; // Changed to multi-select
  String? _selectedProjectId; // Now stores the actual project ID
  String? _selectedProjectName; // Store project name
  DateTime? _startDate;
  DateTime? _endDate;
  List<Attachment> _selectedAttachments = []; // For file attachments

  // API expects these status values
  final List<String> _statusOptions = ['Open', 'In Progress', 'Completed'];
  // Removed hardcoded assignee options - will fetch from provider

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _taskNameController.text = widget.task!.taskName;
      _descriptionController.text = widget.task!.description;
      _selectedStatus = widget.task!.status;
      _startDate = widget.task!.startDate;
      _endDate = widget.task!.endDate;
      _selectedProjectId = widget.task!.projectId;
      _selectedProjectName = widget.task!.projectName;
      
      // Initialize assignees from task data
      // We need to convert assignee IDs and names back to Employee objects
      // For now, we'll create temporary Employee objects with the available data
      if (widget.task!.assignedToId.isNotEmpty && widget.task!.assignedTo.isNotEmpty) {
        final assigneeIds = widget.task!.assignedToId.split(',').map((e) => e.trim()).toList();
        final assigneeNames = widget.task!.assignedTo.split(',').map((e) => e.trim()).toList();
        
        for (int i = 0; i < assigneeIds.length && i < assigneeNames.length; i++) {
          final nameParts = assigneeNames[i].split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts[0] : assigneeNames[i];
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          
          // Create a temporary Employee object with the data we have
          _selectedAssignees.add(Employee(
            userId: assigneeIds[i],
            firstName: firstName,
            lastName: lastName,
            emailId: '', // Not available from task data
            status: 'ACTIVE',
            isConfirmed: true,
            roleId: '',
            roleName: '',
          ));
        }
        debugPrint('✏️ EDIT MODE - Loaded ${_selectedAssignees.length} assignee(s)');
      }
      
      debugPrint('✏️ EDIT MODE - Editing existing task: ${widget.task!.taskName}');
    } else {
      // For new tasks, use the passed projectId if available
      _selectedProjectId = widget.projectId.isNotEmpty ? widget.projectId : null;
      debugPrint('➕ CREATE MODE - Creating new task');
    }
    
    debugPrint('📁 Initial Project ID: "${widget.projectId}"');
    if (widget.projectId.isEmpty) {
      debugPrint('⚠️ WARNING: No project ID provided - will fetch from dropdown');
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

  void _handleSubmit() {
    debugPrint('🔧 SUBMIT - Form submission started');
    
    if (_formKey.currentState!.validate()) {
      debugPrint('✅ Form validation passed');
      
      if (_selectedStatus == null) {
        debugPrint('❌ Status is null');
        _showError('Please select a status');
        return;
      }
      if (_startDate == null) {
        debugPrint('❌ Start date is null');
        _showError('Please select a start date');
        return;
      }
      if (_endDate == null) {
        debugPrint('❌ End date is null');
        _showError('Please select an end date');
        return;
      }
      if (_selectedProjectId == null || _selectedProjectId!.isEmpty) {
        debugPrint('❌ Project ID is empty');
        _showError('Please select a project');
        return;
      }

      debugPrint('✅ All validations passed');
      debugPrint('📝 Task Name: ${_taskNameController.text.trim()}');
      debugPrint('⚡ Status: $_selectedStatus');
      debugPrint('📁 Final Project ID: $_selectedProjectId');
      debugPrint('📅 Start Date: $_startDate');
      debugPrint('📅 End Date: $_endDate');
      debugPrint('👥 Assigned To (Count): ${_selectedAssignees.length}');
      _selectedAssignees.forEach((emp) => debugPrint('   - ${emp.fullName}'));
      debugPrint('📋 Description: ${_descriptionController.text.trim()}');

      final taskId = widget.task?.taskId ?? 'T${DateTime.now().millisecondsSinceEpoch % 1000}';

      final task = Task(
        taskName: _taskNameController.text.trim(),
        taskId: taskId,
        description: _descriptionController.text.trim(),
        status: _selectedStatus!,
        projectId: _selectedProjectId!,
        projectName: _selectedProjectName ?? '', // Use selected project name
        assignedTo: _selectedAssignees.isNotEmpty 
            ? _selectedAssignees.map((e) => e.fullName).join(', ')
            : '',
        assignedToId: _selectedAssignees.isNotEmpty 
            ? _selectedAssignees.map((e) => e.userId).join(',')
            : '',
        startDate: _startDate,
        endDate: _endDate,
        attachmentsForCreation: _selectedAttachments, // Pass attachments here
      );

      debugPrint('📤 Returning task object from dialog');
      Navigator.of(context).pop(task);
    } else {
      debugPrint('❌ Form validation failed');
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

  String _getFileType(String extension) {
    extension = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) return 'image';
    if (extension == 'pdf') return 'pdf';
    if (['doc', 'docx'].contains(extension)) return 'document';
    if (['xlsx', 'xls'].contains(extension)) return 'spreadsheet';
    return 'document';
  }

  IconData _getIconForFileType(String fileType) {
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'spreadsheet':
        return Icons.table_chart;
      default:
        return Icons.attachment;
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
            title: widget.task == null ? 'Add New Task' : 'Edit Task',
            onBack: () => Navigator.of(context).pop(),
            onInfoTap: () {},
          ),
        ),
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
                // Project Dropdown with dynamic projects
                Consumer(
                  builder: (context, ref, child) {
                    final projectsAsync = ref.watch(projectListProvider);
                    
                    return projectsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, st) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('Error loading projects: $error'),
                      ),
                      data: (projects) {
                        final projectMap = {for (var p in projects) p.id: p.projectName};
                        final projectIdList = projects.map((p) => p.id).toList();
                        final projectNameList = projects.map((p) => p.projectName).toList();
                        
                        debugPrint('📦 Projects loaded: ${projectNameList.length} projects');
                        projectNameList.forEach((name) => debugPrint('  - $name'));
                        
                        return CustomPopupDropdown(
                          value: _selectedProjectId != null 
                            ? projectMap[_selectedProjectId!]
                            : null,
                          hint: 'Select Project',
                          items: projectNameList,
                          icon: Icons.folder_outlined,
                          onChanged: (value) {
                            if (value != null) {
                              final selectedId = projectIdList[projectNameList.indexOf(value)];
                              setState(() {
                                _selectedProjectId = selectedId;
                                _selectedProjectName = value;
                              });
                              debugPrint('✅ Project selected: $value (ID: $selectedId)');
                            }
                          },
                        );
                      },
                    );
                  },
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
                            color: colors.secondary,
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
                            color: colors.secondary,
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

                // Assignee Multi-Select Dropdown
                Consumer(
                  builder: (context, ref, child) {
                    final employeesAsync = ref.watch(employeeListProvider);
                    
                    return employeesAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, st) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('Error loading employees: $error'),
                      ),
                      data: (employees) {
                        // Filter only active employees
                        final activeEmployees =
                            employees.where((e) => e.status == 'ACTIVE').toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dropdown field
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.inputBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: DropdownButton<Employee>(
                                isExpanded: true,
                                hint: const Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      color: AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Select Assignees',
                                      style: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                underline: const SizedBox(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                dropdownColor: AppColors.cardBackground,
                                items: activeEmployees.map((employee) {
                                  return DropdownMenuItem<Employee>(
                                    value: employee,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Text(
                                        employee.fullName,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (employee) {
                                  if (employee != null) {
                                    setState(() {
                                      if (_selectedAssignees.any(
                                          (e) => e.userId == employee.userId)) {
                                        _selectedAssignees.removeWhere(
                                            (e) => e.userId == employee.userId);
                                      } else {
                                        _selectedAssignees.add(employee);
                                      }
                                    });
                                    debugPrint(
                                      '✅ Assignee toggled: ${employee.fullName}',
                                    );
                                    debugPrint(
                                      '👥 Total selected: ${_selectedAssignees.length}',
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Chips below the dropdown
                            if (_selectedAssignees.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedAssignees.map((employee) {
                                  return Chip(
                                    label: Text(employee.fullName),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedAssignees.removeWhere(
                                            (e) => e.userId == employee.userId);
                                      });
                                      debugPrint(
                                        '❌ Assignee removed: ${employee.fullName}',
                                      );
                                    },
                                    backgroundColor: AppColors.primary
                                        .withOpacity(0.2),
                                    labelStyle: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                    deleteIconColor: AppColors.primary,
                                  );
                                }).toList(),
                              ),
                          ],
                        );
                      },
                    );
                  },
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

                // Add Attachment Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: true,
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'xlsx', 'xls', 'txt'],
                        );

                        if (result != null) {
                          setState(() {
                            _selectedAttachments.clear();
                            for (var file in result.files) {
                              if (file.path != null) {
                                final attachment = Attachment(
                                  fileName: file.name,
                                  fileType: _getFileType(file.extension ?? ''),
                                  fileSize: file.size,
                                  localFile: File(file.path!),
                                );
                                _selectedAttachments.add(attachment);
                                debugPrint('📎 File selected: ${file.name}');
                              }
                            }
                          });
                        }
                      } catch (e) {
                        debugPrint('❌ Error picking files: $e');
                      }
                    },
                    icon: const Icon(Icons.attach_file, size: 20),
                    label: const Text(
                      'Add Attachment',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Display selected attachments
                if (_selectedAttachments.isNotEmpty)
                  ...(_selectedAttachments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final attachment = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.inputBorder.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getIconForFileType(attachment.fileType),
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attachment.fileName,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${(attachment.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              color: AppColors.error,
                              onPressed: () {
                                setState(() {
                                  _selectedAttachments.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList()),
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
