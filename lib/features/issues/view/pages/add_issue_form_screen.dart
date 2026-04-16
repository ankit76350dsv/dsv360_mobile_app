import 'dart:io';

import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../model/issue_model.dart';
import '../../../../models/project_model.dart';
import '../../../teams/model/employee_model.dart';
import '../../repository/create_issue_repository.dart';
import '../../repository/fetch_projects_repository.dart';
import '../../repository/update_issue_repository.dart';
import '../../../teams/repositories/employee_repository.dart';
import '../../../../views/widgets/bottom_two_buttons.dart';
import '../../../../views/widgets/custom_dropdown_field.dart';
import '../../../../views/widgets/custom_input_field.dart';

class AddIssueFormScreen extends ConsumerStatefulWidget {
  final IssueModel? issue;
  final CreateIssueRepository createIssueRepository;
  final UpdateIssueRepository updateIssueRepository;

  const AddIssueFormScreen({
    super.key,
    this.issue,
    required this.createIssueRepository,
    required this.updateIssueRepository,
  });

  @override
  ConsumerState<AddIssueFormScreen> createState() =>
      _AddIssueFormScreenState();
}

class _AddIssueFormScreenState extends ConsumerState<AddIssueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ProjectModel? _selectedProject;
  List<Employee> _selectedAssignees = [];
  String? _selectedStatus;
  String? _selectedSeverity;
  DateTime? _dueDate;
  final List<XFile> _selectedImages = [];

  List<ProjectModel> _projectList = [];
  List<Employee> _employeeList = [];
  bool _isLoadingProjects = false;
  bool _isLoadingEmployees = false;
  String bottomTwoButtonsLoadingKey = 'add_issue_key';

  final List<String> _statusOptions = [
    'Open',
    'Work In Progress',
    'Resolved',
    'Closed',
  ];
  final List<String> _severityOptions = ['Critical', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _loadEmployees();

    if (widget.issue != null) {
      _issueNameController.text = widget.issue!.issueName;
      _descriptionController.text = widget.issue!.description ?? '';
      _selectedStatus = widget.issue!.status;
      _selectedSeverity = widget.issue!.priority;
      _dueDate = widget.issue!.dueDate;

      // Load project and assignees after data is loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _selectedProject = _projectList.firstWhere(
              (p) => p.id == widget.issue!.projectId,
              orElse: () => _projectList.first,
            );
            // Pre-select assignees from comma-separated assignedTo field
            final assignedNames = (widget.issue!.assignedTo ?? '')
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            _selectedAssignees = _employeeList
                .where((e) => assignedNames.contains(e.fullName))
                .toList();
          });
        }
      });
    }
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoadingProjects = true);
    try {
      final projectRepo = FetchProjectsRepository();
      final projects = await projectRepo.fetchProjects();
      setState(() {
        _projectList = projects;
        _isLoadingProjects = false;
      });
    } catch (e) {
      setState(() => _isLoadingProjects = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading projects: $e')));
      }
    }
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoadingEmployees = true);
    try {
      final employeeRepo = EmployeeRepository();
      final employees = await employeeRepo.fetchAllEmployees();
      setState(() {
        _employeeList = employees;
        _isLoadingEmployees = false;
      });
    } catch (e) {
      setState(() => _isLoadingEmployees = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading employees: $e')));
      }
    }
  }

  @override
  void dispose() {
    _issueNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
  final customColors = Theme.of(context).custom;

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _dueDate ?? DateTime.now(),
    firstDate: widget.issue == null ? DateTime.now() : DateTime(2000),  // Allow past dates when editing
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
          dialogBackgroundColor: customColors.cardBackground,
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      _dueDate = picked;
    });
  }
}

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProject == null) {
        _showError('Please select a project');
        return;
      }
      if (_selectedStatus == null) {
        _showError('Please select a status');
        return;
      }
      if (_selectedSeverity == null) {
        _showError('Please select severity');
        return;
      }
      if (_selectedAssignees.isEmpty) {
        _showError('Please select at least one assignee');
        return;
      }
      if (_dueDate == null) {
        _showError('Please select a due date');
        return;
      }

      final submitLoadingNotifier = ref.read(
        submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier,
      );
      submitLoadingNotifier.state = true;

      try {
        final formattedDate = DateFormat('yyyy-MM-dd').format(_dueDate!);
        final assigneeIds = _selectedAssignees.map((e) => e.userId).join(',');
        final assigneeNames = _selectedAssignees.map((e) => e.fullName).join(',');

        if (widget.issue == null) {
          // Create new issue
          await widget.createIssueRepository.createIssue(
            issueName: _issueNameController.text.trim(),
            description: _descriptionController.text.trim(),
            severity: _selectedSeverity!,
            status: _selectedStatus!,
            projectId: _selectedProject!.id,
            projectName: _selectedProject!.projectName,
            assigneeId: assigneeIds,
            assigneeName: assigneeNames,
            dueDate: formattedDate,
            files: _selectedImages,
          );
        } else {
          // Update existing issue
          await widget.updateIssueRepository.updateIssue(
          issueId: widget.issue!.id,
          issueName: _issueNameController.text.trim(),
          description: _descriptionController.text.trim(),
          severity: _selectedSeverity!,
          status: _selectedStatus!,
          projectId: _selectedProject!.id,
          projectName: _selectedProject!.projectName,  // ✅ ADD THIS
          assigneeId: assigneeIds,
          assigneeName: assigneeNames,  // ✅ ADD THIS
          dueDate: formattedDate,
          files: _selectedImages.isNotEmpty ? _selectedImages : null,
  );
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          _showError(
            'Failed to ${widget.issue == null ? 'create' : 'update'} issue: $e',
          );
        }
      } finally {
        submitLoadingNotifier.state = false;
      }
    }
  }

  Future<void> _handleImageUpload() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(limit: 3);

    if (images.isNotEmpty) {
      if ((_selectedImages.length + images.length) > 3) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only upload up to 3 images')),
          );
        }
        return;
      }

      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _showError(String message) {
    final customColors = Theme.of(context).custom;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: customColors.error!),
    );
  }

  /// Shows a multi-select bottom sheet for assignees.
  void _showAssigneeSelector(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final colorScheme = Theme.of(context).colorScheme;
    final TextEditingController searchController = TextEditingController();
    List<Employee> filtered = List.from(_employeeList);
    // Working copy so we only commit on Save
    List<Employee> tempSelected = List.from(_selectedAssignees);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: customColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (ctx, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Select Assignees',
                            style: TextStyle(
                              color: customColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() => _selectedAssignees = tempSelected);
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: customColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: customColors.inputFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.20),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            const Icon(Icons.search, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                autofocus: true,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: customColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Search assignee',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                onChanged: (value) {
                                  setSheetState(() {
                                    final q = value.toLowerCase().trim();
                                    filtered = q.isEmpty
                                        ? List.from(_employeeList)
                                        : _employeeList
                                            .where((e) => e.fullName.toLowerCase().contains(q))
                                            .toList();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (ctx, index) {
                          final employee = filtered[index];
                          final isSelected = tempSelected.any((e) => e.userId == employee.userId);
                          return InkWell(
                            onTap: () {
                              setSheetState(() {
                                if (isSelected) {
                                  tempSelected.removeWhere((e) => e.userId == employee.userId);
                                } else {
                                  tempSelected.add(employee);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.12)
                                    : customColors.cardBackground,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      employee.fullName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.blue.shade400
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_rounded, size: 16, color: Colors.blue.shade400),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).custom;

    // Helper: get display label for a dropdown item by its value
    String labelForValue(List<DropdownMenuItem<String>> items, String? value) {
      if (value == null) return '';
      try {
        final item = items.firstWhere((i) => i.value == value);
        final child = item.child;
        if (child is Text) return child.data ?? value;
      } catch (_) {}
      return value;
    }

    final List<DropdownMenuItem<String>> projectOptions = _projectList
        .map(
          (project) => DropdownMenuItem<String>(
            value: project.id,
            child: Text(project.projectName),
          ),
        )
        .toList();

    final List<DropdownMenuItem<String>> statusOptions = _statusOptions
        .map(
          (status) =>
              DropdownMenuItem<String>(value: status, child: Text(status)),
        )
        .toList();

    final List<DropdownMenuItem<String>> severityOptions = _severityOptions
        .map(
          (severity) =>
              DropdownMenuItem<String>(value: severity, child: Text(severity)),
        )
        .toList();

    // Assignees display string
    final assigneesLabel = _selectedAssignees.isEmpty
        ? null
        : _selectedAssignees.map((e) => e.fullName).join(', ');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.issue == null ? 'Add Issue' : 'Edit Issue',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                widget.issue == null
                    ? 'Add Issue Details'
                    : 'Edit Issue Details',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInputField(
                        controller: _issueNameController,
                        hintText: 'Issue Name',
                        labelText: 'Issue Name',
                        prefixIcon: Icons.bug_report_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter issue name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      CustomDropDownField(
                        hintText: _isLoadingProjects
                            ? 'Loading projects...'
                            : 'Select project',
                        labelText: 'Project',
                        prefixIcon: Icons.folder_outlined,
                        searchable: true,
                        searchHintText: 'Search project',
                        options: projectOptions,
                        selectedOption: _selectedProject == null
                            ? null
                            : labelForValue(projectOptions, _selectedProject!.id),
                        onChanged: projectOptions.isEmpty
                            ? (value) {}
                            : (value) => setState(() {
                                _selectedProject = _projectList.firstWhere(
                                  (project) => project.id == value,
                                  orElse: () => _projectList.first,
                                );
                              }),
                      ),
                      const SizedBox(height: 20),

                      CustomDropDownField(
                        hintText: 'Select status',
                        labelText: 'Status',
                        prefixIcon: Icons.assignment_outlined,
                        searchable: true,
                        searchHintText: 'Search status',
                        options: statusOptions,
                        selectedOption: _selectedStatus,
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                        },
                      ),
                      const SizedBox(height: 20),

                      CustomDropDownField(
                        hintText: 'Select severity',
                        labelText: 'Severity',
                        prefixIcon: Icons.warning_outlined,
                        searchable: true,
                        searchHintText: 'Search severity',
                        options: severityOptions,
                        selectedOption: _selectedSeverity,
                        onChanged: (value) {
                          setState(() => _selectedSeverity = value);
                        },
                      ),
                      const SizedBox(height: 20),

                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: customColors.inputFill!,
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
                                child: Text(
                                  _dueDate == null
                                      ? 'Due Date'
                                      : DateFormat(
                                          'dd-MM-yyyy',
                                        ).format(_dueDate!),
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
                      const SizedBox(height: 20),

                      // Multi-select assignees field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assignee',
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _isLoadingEmployees
                                ? null
                                : () => _showAssigneeSelector(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: customColors.inputFill,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colors.outline.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 20,
                                    color: Colors.grey.withOpacity(0.85),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _isLoadingEmployees
                                          ? 'Loading assignees...'
                                          : (assigneesLabel ?? 'Select assignee'),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: assigneesLabel == null
                                            ? Colors.grey
                                            : customColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: customColors.textPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      CustomInputField(
                        controller: _descriptionController,
                        hintText: 'Description',
                        labelText: 'Issue Description',
                        prefixIcon: Icons.description_outlined,
                        isMultiline: true,
                        maxLines: 4,
                        minLines: 4,
                      ),
                      if (widget.issue == null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Upload up to 3 images',
                          style: TextStyle(
                            color: customColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedImages.isNotEmpty) ...[
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _selectedImages.asMap().entries.map((entry) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: customColors.inputFill,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.file(
                                        File(_selectedImages[entry.key].path),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.image,
                                            size: 40,
                                            color: customColors.textSecondary,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: customColors.error,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImages.removeAt(entry.key);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        OutlinedButton.icon(
                          onPressed: _selectedImages.length < 3
                              ? _handleImageUpload
                              : null,
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: const Text(
                            'ATTACHMENT',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: customColors.primary,
                            side: BorderSide(color: customColors.primary!),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: 'cancel',
                        button2Text: widget.issue == null ? 'add' : 'update',
                        button1Function: () {
                          Navigator.pop(context);
                        },
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            _handleSubmit();
                          }
                        },
                      ),
                      const SizedBox(height: 40),
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
