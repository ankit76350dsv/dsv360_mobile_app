import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/issue_model.dart';
import '../../models/project_model.dart';
import '../../models/employee.dart';
import '../../repositories/issue_repository.dart';
import '../../repositories/project_repository.dart';
import '../../repositories/employee_repository.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/TopBar.dart';

class AddIssueFormScreen extends StatefulWidget {
  final IssueModel? issue;
  final IssueRepository issueRepository;

  const AddIssueFormScreen({
    super.key,
    this.issue,
    required this.issueRepository,
  });

  @override
  State<AddIssueFormScreen> createState() => _AddIssueFormScreenState();
}

class _AddIssueFormScreenState extends State<AddIssueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ProjectModel? _selectedProject;
  Employee? _selectedAssignee;
  String? _selectedStatus;
  String? _selectedSeverity;
  DateTime? _dueDate;
  
  List<ProjectModel> _projectList = [];
  List<Employee> _employeeList = [];
  bool _isLoadingProjects = false;
  bool _isLoadingEmployees = false;
  bool _isSubmitting = false;

  final List<String> _statusOptions = ['Open', 'Work In Progress', 'Resolved', 'Closed'];
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
      
      // Load project and assignee after data is loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _selectedProject = _projectList.firstWhere(
              (p) => p.id == widget.issue!.projectId,
              orElse: () => _projectList.first,
            );
            _selectedAssignee = _employeeList.firstWhere(
              (e) => e.fullName == widget.issue!.assignedTo,
              orElse: () => _employeeList.first,
            );
          });
        }
      });
    }
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoadingProjects = true);
    try {
      final projectRepo = ProjectRepository();
      final projects = await projectRepo.fetchProjects();
      setState(() {
        _projectList = projects;
        _isLoadingProjects = false;
      });
    } catch (e) {
      setState(() => _isLoadingProjects = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading projects: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading employees: $e')),
        );
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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
      if (_selectedAssignee == null) {
        _showError('Please select an assignee');
        return;
      }
      if (_dueDate == null) {
        _showError('Please select a due date');
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final formattedDate = DateFormat('yyyy-MM-dd').format(_dueDate!);
        
        if (widget.issue == null) {
          // Create new issue
          await widget.issueRepository.createIssue(
            issueName: _issueNameController.text.trim(),
            description: _descriptionController.text.trim(),
            severity: _selectedSeverity!,
            status: _selectedStatus!,
            projectId: _selectedProject!.id,
            assigneeId: _selectedAssignee!.userId,
            dueDate: formattedDate,
          );
        } else {
          // Update existing issue
          await widget.issueRepository.updateIssue(
            issueId: widget.issue!.id,
            issueName: _issueNameController.text.trim(),
            description: _descriptionController.text.trim(),
            severity: _selectedSeverity!,
            status: _selectedStatus!,
            projectId: _selectedProject!.id,
            assigneeId: _selectedAssignee!.userId,
            dueDate: formattedDate,
          );
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        setState(() => _isSubmitting = false);
        if (mounted) {
          _showError('Failed to ${widget.issue == null ? 'create' : 'update'} issue: $e');
        }
      }
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
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: TopBar(
            title: widget.issue == null ? 'Add New Issue' : 'Edit Issue',
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
                // Issue Name
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

                // Project Dropdown
                _isLoadingProjects
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<ProjectModel>(
                        value: _selectedProject,
                        hint: const Text(
                          'Select Project',
                          style: TextStyle(color: AppColors.textHint),
                        ),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                        dropdownColor: colors.secondary,
                        decoration: InputDecoration(
                          labelText: 'Project',
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: colors.secondary,
                          prefixIcon: const Icon(Icons.folder_outlined, color: AppColors.textSecondary),
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
                        items: _projectList.map((project) {
                          return DropdownMenuItem(
                            value: project,
                            child: Text(project.projectName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedProject = value);
                        },
                      ),
                const SizedBox(height: 20),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  hint: const Text(
                    'Status',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                  dropdownColor: colors.secondary,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: colors.secondary,
                    prefixIcon: const Icon(Icons.assignment_outlined, color: AppColors.textSecondary),
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
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
                const SizedBox(height: 20),

                // Severity Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSeverity,
                  hint: const Text(
                    'Severity',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                  dropdownColor: colors.secondary,
                  decoration: InputDecoration(
                    labelText: 'Severity',
                    labelStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: colors.secondary,
                    prefixIcon: const Icon(Icons.warning_outlined, color: AppColors.textSecondary),
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
                  items: _severityOptions.map((severity) {
                    return DropdownMenuItem(
                      value: severity,
                      child: Text(severity),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSeverity = value);
                  },
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
                            _dueDate == null
                                ? 'Due Date'
                                : DateFormat('dd-MM-yyyy').format(_dueDate!),
                            style: TextStyle(
                              color: _dueDate == null
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
                const SizedBox(height: 20),

                // Assignee Dropdown
                _isLoadingEmployees
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<Employee>(
                        value: _selectedAssignee,
                        hint: const Text(
                          'Select Assignee',
                          style: TextStyle(color: AppColors.textHint),
                        ),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                        dropdownColor: colors.secondary,
                        decoration: InputDecoration(
                          labelText: 'Assignee',
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: colors.secondary,
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
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
                        items: _employeeList.map((employee) {
                          return DropdownMenuItem(
                            value: employee,
                            child: Text(employee.fullName ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedAssignee = value);
                        },
                      ),
                const SizedBox(height: 20),

                // Description
                CustomInputField(
                  controller: _descriptionController,
                  hintText: 'Description',
                  labelText: 'Issue Description',
                  prefixIcon: Icons.description_outlined,
                  isMultiline: true,
                  maxLines: 4,
                  minLines: 4,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.issue == null ? 'ADD' : 'UPDATE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
