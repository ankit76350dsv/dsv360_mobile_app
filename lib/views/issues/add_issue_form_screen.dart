import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/issue_model.dart';
import '../widgets/custom_input_field.dart';

class AddIssueFormScreen extends StatefulWidget {
  final IssueModel? issue; // For edit mode

  const AddIssueFormScreen({super.key, this.issue});

  @override
  State<AddIssueFormScreen> createState() => _AddIssueFormScreenState();
}

class _AddIssueFormScreenState extends State<AddIssueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedProject;
  String? _selectedStatus;
  String? _selectedSeverity;
  DateTime? _dueDate;
  List<String> _selectedAssignees = [];
  final List<String> _attachments = [];

  final List<String> _projectOptions = ['Demo Session', 'Mobile App', 'Web Portal'];
  final List<String> _statusOptions = ['Open', 'In Progress', 'Resolved', 'Closed', 'On Hold'];
  final List<String> _severityOptions = ['Critical', 'High', 'Medium', 'Low'];
  final List<String> _assigneeOptions = ['Aman Jain', 'Patel Kumar', 'John Cena', 'John Doe', 'Jane Smith'];

  @override
  void initState() {
    super.initState();
    if (widget.issue != null) {
      _issueNameController.text = widget.issue!.issueName;
      _descriptionController.text = widget.issue!.description ?? '';
      _selectedProject = widget.issue!.projectName;
      _selectedStatus = widget.issue!.status;
      _selectedSeverity = widget.issue!.priority;
      _dueDate = widget.issue!.dueDate;
      if (widget.issue!.assignedTo != null) {
        _selectedAssignees = [widget.issue!.assignedTo!];
      }
      _attachments.addAll(widget.issue!.attachments);
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

  void _toggleAssignee(String assignee) {
    setState(() {
      if (_selectedAssignees.contains(assignee)) {
        _selectedAssignees.remove(assignee);
      } else {
        _selectedAssignees.add(assignee);
      }
    });
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
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleSubmit() {
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
      if (_dueDate == null) {
        _showError('Please select a due date');
        return;
      }

      final issue = IssueModel(
        id: widget.issue?.id ?? 'I${DateTime.now().millisecondsSinceEpoch % 10000}',
        issueName: _issueNameController.text.trim(),
        status: _selectedStatus!,
        priority: _selectedSeverity!,
        description: _descriptionController.text.trim(),
        assignedTo: _selectedAssignees.isNotEmpty ? _selectedAssignees.first : null,
        createdDate: widget.issue?.createdDate ?? DateTime.now(),
        dueDate: _dueDate,
        projectId: 'P${DateTime.now().millisecondsSinceEpoch % 10000}',
        projectName: _selectedProject,
        attachments: List.from(_attachments),
        commentsCount: widget.issue?.commentsCount ?? 0,
      );

      Navigator.of(context).pop(issue);
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
        title: Text(widget.issue == null ? 'Add New Issue' : 'Edit Issue'),
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
                DropdownButtonFormField<String>(
                  value: _selectedProject,
                  hint: const Text(
                    'Select Project',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                  dropdownColor: AppColors.inputFill,
                  decoration: InputDecoration(
                    labelText: 'Project',
                    labelStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.inputFill,
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
                  items: _projectOptions.map((project) {
                    return DropdownMenuItem(
                      value: project,
                      child: Text(project),
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
                  dropdownColor: AppColors.inputFill,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.inputFill,
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
                  dropdownColor: AppColors.inputFill,
                  decoration: InputDecoration(
                    labelText: 'Severity',
                    labelStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.inputFill,
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

                // Assignee Multi-Select
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.inputBorder,
                          width: 1.5,
                        ),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            Icon(Icons.person_outline, color: AppColors.textSecondary, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Select Assignee',
                              style: TextStyle(color: AppColors.textHint, fontSize: 14),
                            ),
                          ],
                        ),
                        underline: const SizedBox(),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        dropdownColor: AppColors.cardBackground,
                        items: _assigneeOptions.map((assignee) {
                          return DropdownMenuItem(
                            value: assignee,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(assignee, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _toggleAssignee(value);
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
                        children: _selectedAssignees.map((assignee) {
                          return Chip(
                            label: Text(assignee),
                            onDeleted: () => _toggleAssignee(assignee),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                            labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            deleteIconColor: AppColors.primary,
                          );
                        }).toList(),
                      ),
                  ],
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
                const SizedBox(height: 20),

                // Add Attachment Button
                OutlinedButton.icon(
                  onPressed: _handleAddAttachment,
                  icon: const Icon(Icons.attach_file, color: AppColors.primary),
                  label: const Text(
                    'ADD ATTACHMENT',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Text(
                          'ADD',
                          style: TextStyle(
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
