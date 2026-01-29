import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../models/employee.dart';
import '../../models/attachment.dart';
import '../../repositories/project_repository.dart';
import '../../repositories/employee_repository.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_popup_dropdown.dart';
import '../widgets/TopBar.dart';

class AddProjectDialog extends StatefulWidget {
  final ProjectModel? project; // For edit mode
  final ProjectRepository projectRepository;
  final EmployeeRepository employeeRepository;

  const AddProjectDialog({
    super.key,
    this.project,
    required this.projectRepository,
    required this.employeeRepository,
  });

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedClient;
  String? _selectedStatus;
  Employee? _selectedEmployee;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<Attachment> _attachments = [];

  List<Employee> _employeeList = [];
  bool _isLoadingEmployees = false;
  bool _isSubmitting = false;

  final List<String> _clientOptions = ['Wipro', 'Test', 'Bala & Co', 'TCS'];
  final List<String> _statusOptions = ['Open', 'Work In Process', 'Completed', 'Closed', 'On Hold'];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    
    if (widget.project != null) {
      _projectNameController.text = widget.project!.projectName;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedClient = widget.project!.client;
      _selectedStatus = widget.project!.status;
      _startDate = widget.project!.startDate;
      _endDate = widget.project!.endDate;
      
      // Convert existing attachment URLs to Attachment objects
      for (var url in widget.project!.attachments) {
        _attachments.add(Attachment(
          fileName: url.split('/').last,
          fileType: _getFileType(url),
          fileSize: 0,
          fileUrl: url,
        ));
      }
    }
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoadingEmployees = true);
    try {
      final employees = await widget.employeeRepository.fetchAllEmployees();
      setState(() {
        _employeeList = employees;
        // Set selected employee if in edit mode
        if (widget.project != null && widget.project!.assignedToId != null) {
          final targetId = widget.project!.assignedToId!;
          try {
            _selectedEmployee = employees.firstWhere(
              (e) => e.userId.toString() == targetId.toString(),
            );
          } catch (e) {
            _selectedEmployee = employees.isNotEmpty ? employees.first : null;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        _showError('Failed to load employees: $e');
      }
    } finally {
      setState(() => _isLoadingEmployees = false);
    }
  }

  String _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext)) return 'image';
    if (['pdf'].contains(ext)) return 'pdf';
    if (['doc', 'docx'].contains(ext)) return 'document';
    if (['xls', 'xlsx'].contains(ext)) return 'spreadsheet';
    return 'file';
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
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

  Future<void> _handleAddAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'xls', 'xlsx'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final attachment = Attachment(
          fileName: file.name,
          fileType: _getFileType(file.name),
          fileSize: file.size,
          localFile: File(file.path!),
        );

        setState(() {
          _attachments.add(attachment);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${file.name} added'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to pick file: $e');
      }
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClient == null) {
        _showError('Please select a client');
        return;
      }
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

      setState(() => _isSubmitting = true);

      try {
        // Hardcoded client IDs based on client name (you can make this dynamic later)
        final clientIdMap = {
          'Wipro': '17682000000675650',
          'Test': '17682000000675651',
          'Bala & Co': '17682000000675652',
          'TCS': '17682000000675653',
        };

        final clientId = clientIdMap[_selectedClient] ?? '17682000000675650';

        if (widget.project == null) {
          // Create new project
          await widget.projectRepository.createProject(
            projectName: _projectNameController.text.trim(),
            status: _selectedStatus!,
            clientId: clientId,
            startDate: _startDate!,
            endDate: _endDate!,
            assignedToId: _selectedEmployee?.userId,
            description: _descriptionController.text.trim(),
            attachments: _attachments.isEmpty ? null : _attachments,
          );

          if (mounted) {
            Navigator.of(context).pop({'success': true, 'action': 'create'});
          }
        } else {
          // Update existing project
          await widget.projectRepository.updateProject(
            projectId: widget.project!.id,
            projectName: _projectNameController.text.trim(),
            status: _selectedStatus!,
            clientId: clientId,
            startDate: _startDate!,
            endDate: _endDate!,
            assignedToId: _selectedEmployee?.userId,
            description: _descriptionController.text.trim(),
            attachments: _attachments.isEmpty ? null : _attachments,
          );

          if (mounted) {
            Navigator.of(context).pop({'success': true, 'action': 'update'});
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          _showError('Failed to ${widget.project == null ? "create" : "update"} project: $e');
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
            title: widget.project == null ? 'Add New Project' : 'Edit Project',
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
              // Project Name
              CustomInputField(
                        controller: _projectNameController,
                        hintText: 'Project Name',
                        labelText: 'Project Name',
                        prefixIcon: Icons.folder_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter project name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Client Name Dropdown
                      CustomPopupDropdown(
                        value: _selectedClient,
                        hint: 'Client Name',
                        items: _clientOptions,
                        icon: Icons.business_outlined,
                        onChanged: (value) {
                          setState(() => _selectedClient = value);
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

                      // Employee Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
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
                              Icons.person_outline,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _isLoadingEmployees
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Text(
                                        'Loading employees...',
                                        style: TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : DropdownButton<Employee>(
                                      value: _selectedEmployee,
                                      hint: const Text(
                                        'Assign To',
                                        style: TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      dropdownColor: AppColors.cardBackground,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColors.textSecondary,
                                      ),
                                      items: _employeeList.map((Employee employee) {
                                        return DropdownMenuItem<Employee>(
                                          value: employee,
                                          child: Text(employee.fullName),
                                        );
                                      }).toList(),
                                      onChanged: (Employee? value) {
                                        setState(() => _selectedEmployee = value);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      CustomInputField(
                        controller: _descriptionController,
                        hintText: 'Description',
                        labelText: 'Project Description',
                        prefixIcon: Icons.description_outlined,
                        isMultiline: true,
                        maxLines: 4,
                        minLines: 4,
                      ),
                      const SizedBox(height: 24),

                      // Attachments
                      if (_attachments.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _attachments.asMap().entries.map((entry) {
                            return Chip(
                              label: Text(entry.value.fileName),
                              deleteIcon: const Icon(Icons.close, size: 18),
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
                        onPressed: _isSubmitting ? null : _handleAddAttachment,
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
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
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
                              widget.project == null ? 'ADD' : 'UPDATE',
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
        ));
  }
}

