import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/features/sprints/viewmodel/epic_release_viewmodel.dart';
import 'package:dsv360/features/sprints/viewmodel/sprints_project_viewmodel.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CreateReleasePage extends ConsumerStatefulWidget {
  final String? projectId;
  final String? projectName;

  const CreateReleasePage({super.key, this.projectId, this.projectName});

  @override
  ConsumerState<CreateReleasePage> createState() => _CreateReleasePageState();
}

class _CreateReleasePageState extends ConsumerState<CreateReleasePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _releaseDate;

  String? _selectedProjectId;
  List<ProjectModel> _projects = [];
  bool _isProjectsLoading = false;
  bool _hasProjectsError = false;

  final String _loadingKey = 'create_release_key';

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
    _fetchProjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchProjects() async {
    setState(() {
      _isProjectsLoading = true;
      _hasProjectsError = false;
    });
    try {
      _projects = await ref.read(projectRepositoryProvider).fetchProjects();
    } catch (_) {
      _hasProjectsError = true;
      _projects = [];
    } finally {
      if (mounted) setState(() => _isProjectsLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final customColors = Theme.of(context).custom;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate ?? DateTime.now(),
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
            dialogTheme: DialogThemeData(backgroundColor: customColors.cardBackground!),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _releaseDate = picked);
    }
  }

  Future<void> _createRelease() async {
    if (_selectedProjectId == null || _selectedProjectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project')),
      );
      return;
    }

    if (_releaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a release date')),
      );
      return;
    }

    final submitLoadingNotifier =
        ref.read(submitLoadingProvider(_loadingKey).notifier);
    submitLoadingNotifier.state = true;

    try {
      final repo = ref.read(createReleaseRepositoryProvider);
      final formattedDate = DateFormat('yyyy-MM-dd').format(_releaseDate!);

      await repo.createRelease(
        title: _titleController.text.trim(),
        projctID: _selectedProjectId!,
        description: _descriptionController.text.trim(),
        dueDate: formattedDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Release created successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final errorText = e.toString();
      debugPrint('error here');
      debugPrint(errorText);
      final message = errorText.contains('do not have permission')
          ? 'Permission denied from server, please try again.'
          : 'Failed to create release. Please try again.';

      showErrorSnackBar(context, message);
    } finally {
      submitLoadingNotifier.state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).custom;

    final projectItems = [
      if (widget.projectId != null &&
          widget.projectName != null &&
          !_projects.any((p) => p.id == widget.projectId))
        DropdownMenuItem<String>(
          value: widget.projectId!,
          child: Text(widget.projectName!),
        ),
      ..._projects.map((p) => DropdownMenuItem<String>(
            value: p.id,
            child: Text(p.projectName),
          )),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Release',
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
                'Release Details',
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
                      // Project dropdown
                      CustomDropDownField(
                        hintText: _isProjectsLoading
                            ? 'Loading projects...'
                            : _hasProjectsError
                                ? 'Failed to load projects'
                                : widget.projectName ?? 'Select Project',
                        labelText: 'Project *',
                        prefixIcon: Icons.folder_outlined,
                        searchable: true,
                        searchHintText: 'Search project',
                        options: projectItems,
                        selectedOption: _selectedProjectId,
                        onChanged: (value) {
                          setState(() => _selectedProjectId = value);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Release Title
                      CustomInputField(
                        controller: _titleController,
                        hintText: 'Release Title',
                        labelText: 'Release Title',
                        prefixIcon: Icons.rocket_launch_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter release title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Release Date
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
                                  _releaseDate == null
                                      ? 'Release Date'
                                      : DateFormat('dd-MM-yyyy').format(_releaseDate!),
                                  style: TextStyle(
                                    color: _releaseDate == null
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

                      // Description
                      CustomInputField(
                        controller: _descriptionController,
                        hintText: 'Description',
                        isMultiline: true,
                        labelText: 'Description',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter description';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      BottomTwoButtons(
                        loadingKey: _loadingKey,
                        button1Text: 'cancel',
                        button2Text: 'create release',
                        button1Function: () => Navigator.pop(context),
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            _createRelease();
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
