import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/sprints/repositories/create_sprint_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:intl/intl.dart';

class CreateSprintPage extends ConsumerStatefulWidget {
  final String projectId;
  final String? projectName;
  const CreateSprintPage({super.key, 
  required this.projectId,this.projectName});

  @override
  ConsumerState<CreateSprintPage> createState() => _CreateSprintPageState();
}

class _CreateSprintPageState extends ConsumerState<CreateSprintPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _sprintNameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  String bottomTwoButtonsLoadingKey = 'create_sprint_key';

  @override
  void dispose() {
    _sprintNameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  // ---------------- DATE PICKER (MATCH TASK PAGE) ----------------

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final customColors = Theme.of(context).custom;

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

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;

          // ✅ enforce: end date cannot be before start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // ---------------- CREATE SPRINT ----------------

  Future<void> _createSprint(BuildContext context) async {
  if (_startDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select start date')),
    );
    return;
  }

  if (_endDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select end date')),
    );
    return;
  }

  final repo = ref.read(createSprintRepositoryProvider);

  final submitLoadingNotifier =
      ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier);

  submitLoadingNotifier.state = true;

  try {
    final sprint = await repo.createSprint(
      sprintName: _sprintNameController.text.trim(),
      goal: _goalController.text.trim(),
      projectId: widget.projectId, 
      startDate: _startDate!.toIso8601String().split('T')[0],
      endDate: _endDate!.toIso8601String().split('T')[0],
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sprint created successfully')),
    );

    Navigator.pop(context, sprint); // return created sprint

  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to create sprint')),
    );
  } finally {
    submitLoadingNotifier.state = false;
  }
}

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).custom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Sprint',
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
                'Sprint Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              
            ),
                          Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        color: colors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Project: ${widget.projectName ?? 'Unknown'}',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                      // Sprint Name
                      CustomInputField(
                        controller: _sprintNameController,
                        hintText: 'Sprint Name',
                        labelText: 'Sprint Name',
                        prefixIcon: Icons.flag,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter sprint name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                  

                      // ---------------- DATE UI (EXACT MATCH) ----------------
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
                                  color: customColors.inputFill,
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
                                        _startDate == null
                                            ? 'Start Date'
                                            : DateFormat('dd-MM-yyyy')
                                                .format(_startDate!),
                                        style: TextStyle(
                                          color: _startDate == null
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
                                  color: customColors.inputFill,
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
                                        _endDate == null
                                            ? 'End Date'
                                            : DateFormat('dd-MM-yyyy')
                                                .format(_endDate!),
                                        style: TextStyle(
                                          color: _endDate == null
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
                          ),
                        ],
                      ),

                      const SizedBox(height: 20,),


                       // Goal
                      CustomInputField(
                        controller: _goalController,
                        hintText: 'Sprint Goal',
                        labelText: 'Goal',
                        prefixIcon: Icons.track_changes,
                        isMultiline: true,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter sprint goal';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: 'cancel',
                        button2Text: 'create sprint',
                        button1Function: () => Navigator.pop(context),
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            _createSprint(context);
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