import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/sprints/model/release_milestone_model.dart';
import 'package:dsv360/features/sprints/repositories/create_epic_repository.dart';
import 'package:dsv360/features/sprints/repositories/get_projects_repository.dart';
import 'package:dsv360/features/sprints/repositories/heirarchy_repository.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateEpicPage extends ConsumerStatefulWidget {
  final String? projectId;
  final String? projectName;
  final String? milestoneId;
  final String? releaseName;

  const CreateEpicPage({
    super.key,
    this.projectId,
    this.projectName,
    this.milestoneId, //release is referred as milestone
    this.releaseName,
  });

  @override
  ConsumerState<CreateEpicPage> createState() => _CreateEpicPageState();
}

class _CreateEpicPageState extends ConsumerState<CreateEpicPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final String _loadingKey = 'create_epic_key';

  String? _selectedColor;
  String? _selectedProjectId;
  String? _selectedMilestoneId;
  String? _selectedMilestoneName;

  List<ProjectModel> _projects = [];
  List<ReleaseMilestoneModel> _milestones = [];
  bool _isProjectsLoading = false;
  bool _hasProjectsError = false;

  bool _isMilestonesLoading = false;
  bool _hasMilestonesError = false;

  final List<String> _colors = [
    "#FA9921",
    "#FAC304",
    "#2A53CC",
    "#2AA3BF",
    "#58D8A4",
    "#8677D9",
    "#5244AA",
    "#FA7353",
    "#3984FF",
    "#34C7E6",
    "#138759",
    "#DD350C",
  ];

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
    // if (widget.projectId == null) {
    //   _fetchProjects();
    // }
    _selectedMilestoneId = widget.milestoneId;
    _selectedMilestoneName = widget.releaseName;

    _fetchProjects();
    if (_selectedProjectId != null && _selectedProjectId!.isNotEmpty) {
      _fetchMilestones(_selectedProjectId!);
    }
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

    Future<void> _fetchMilestones(String projectId) async {
    setState(() {
      _isMilestonesLoading = true;
      _hasMilestonesError = false;
      _milestones = [];
    });
    try {
      final hierarchy = await ref
          .read(hierarchyRepositoryProvider)
          .fetchHierarchy(projectId: projectId);
      _milestones = hierarchy.milestones;

      if (_selectedMilestoneId != null &&
          !_milestones.any((m) => m.id == _selectedMilestoneId)) {
        _selectedMilestoneId = null;
      }
    } catch (_) {
      _hasMilestonesError = true;
      _milestones = [];
    } finally {
      if (mounted) setState(() => _isMilestonesLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createEpic() async {
    if (_selectedProjectId == null || _selectedProjectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project')),
      );
      return;
    }

    if (_selectedMilestoneId == null || _selectedMilestoneId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a release')),
      );
      return;
    }

    if (_selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a color')),
      );
      return;
    }

    final submitLoadingNotifier =
        ref.read(submitLoadingProvider(_loadingKey).notifier);
    submitLoadingNotifier.state = true;

    try {
      final repo = ref.read(createEpicRepositoryProvider);

      await repo.createEpic(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        projectId: _selectedProjectId!,
        //milestoneId: widget.milestoneId ?? '',
        milestoneId: _selectedMilestoneId!,
        color: _selectedColor!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Epic created successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create epic')),
      );
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
          widget.projectName!= null &&
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

    final milestoneItems = _milestones
        .map(
          (m) => DropdownMenuItem<String>(
            value: m.id,
            child: Text(m.title),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Epic',
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
                'Epic Details',
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
                          setState(() {
                            _selectedProjectId = value;
                            _selectedMilestoneId = null;
                            _selectedMilestoneName = null;
                            _milestones = [];
                          });
                          if (value != null && value.isNotEmpty) {
                            _fetchMilestones(value);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      CustomDropDownField(
                        hintText: _selectedProjectId == null
                            ? 'Select project first'
                            : _isMilestonesLoading
                                ? 'Loading release...'
                                : _hasMilestonesError
                                    ? 'Failed to load release'
                                    : _selectedMilestoneName ?? 'Select release',
                        labelText: 'Release*',
                        prefixIcon: Icons.new_releases_outlined,
                        searchable: true,
                        searchHintText: 'Search release',
                        options: milestoneItems,
                        selectedOption: _selectedMilestoneId,
                        onChanged: milestoneItems.isEmpty
                            ? (_) {}
                            : (value) {
                                final name = _milestones
                                    .where((m) => m.id == value)
                                    .map((m) => m.title)
                                    .firstOrNull;
                                setState(() {
                                  _selectedMilestoneId = value;
                                  _selectedMilestoneName = name;
                                });
                              },
                      ),

                      const SizedBox(height: 20),

                      /// Epic Title
                      CustomInputField(
                        controller: _titleController,
                        hintText: 'Epic Title',
                        labelText: 'Epic Title',
                        prefixIcon: Icons.flag_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter epic title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Description
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

                      const SizedBox(height: 20),

                      /// Color Picker
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: customColors.inputFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: customColors.inputBorder!,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Epic Color',
                              style: TextStyle(
                                color: customColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),

                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _colors.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final colorHex = _colors[index];
                                  final color = Color(
                                    int.parse(colorHex.replaceAll('#', '0xFF')),
                                  );

                                  final isSelected = _selectedColor == colorHex;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = colorHex;
                                      });
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? colors.primary
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      BottomTwoButtons(
                        loadingKey: _loadingKey,
                        button1Text: 'cancel',
                        button2Text: 'create epic',
                        button1Function: () => Navigator.pop(context),
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            _createEpic();
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
