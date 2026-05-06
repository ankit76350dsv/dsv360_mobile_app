import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:dsv360/features/badges/repositories/fetch_badge_users_repository.dart';
import 'package:dsv360/features/sprints/model/epic_model.dart';
import 'package:dsv360/features/sprints/model/sprints_model.dart';
import 'package:dsv360/features/sprints/repositories/create_story_repository.dart';
import 'package:dsv360/features/sprints/repositories/get_projects_repository.dart';
import 'package:dsv360/features/sprints/repositories/get_sprints_repository.dart';
import 'package:dsv360/features/sprints/repositories/heirarchy_repository.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateStoryPage extends ConsumerStatefulWidget {
  final String? projectId;
  final String? sprintId;
  final String? epicId;
  final String? projectNameSelected;
  final String? sprintNameSelected;
  final String? epicName;
  final String? status;

  const CreateStoryPage({
    super.key,
    this.projectId,
    this.sprintId,
    this.epicId,
    this.projectNameSelected,
    this.sprintNameSelected,
    this.epicName,
    this.status,
  });

  @override
  ConsumerState<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends ConsumerState<CreateStoryPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _groupNameController = TextEditingController();
  final _moduleNameController = TextEditingController();
  final _fiRemarksController = TextEditingController();
  final _clientRemarksController = TextEditingController();

  final String _loadingKey = 'create_story_key';

  // Dropdown selections
  String? _selectedProjectId;
  String? _selectedSprintId;
  String? _selectedEpicId;
  String? _selectedAssigneeId;
  String? _selectedPrimaryOwnerId;
  String? _selectedSecondaryOwnerId;
  String _status = 'NOT_STARTED';
  String _priority = 'MEDIUM';
  int _points = 3;
  String? _requirementType;
  String? _billingType;
  String? _zohoProductName;

  // Loaded data
  List<ProjectModel> _projects = []; //projects declared here
  List<SprintModel> _sprints = [];
  List<EpicModel> _epics = [];
  List<BadgeUser> _users = [];

  bool _isProjectsLoading = false;
  bool _isSprintsLoading = false;
  bool _isEpicsLoading = false;
  bool _isUsersLoading = false;

  bool _hasProjectsError = false;
  bool _hasSprintsError = false;
  bool _hasEpicsError = false;
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

  static const List<Map<String, String>> _priorityOptions = [
    {'label': 'Low', 'value': 'LOW'},
    {'label': 'Medium', 'value': 'MEDIUM'},
    {'label': 'High', 'value': 'HIGH'},
    {'label': 'Critical', 'value': 'CRITICAL'},
  ];

  static const List<String> _requirementTypeOptions = [
    'New Requirement',
    'Enhancement',
    'Bug Fix',
    'Change Request',
    'Support',
  ];

  static const List<String> _billingTypeOptions = [
    'Billable',
    'Non-Billable',
    'Internal',
  ];

  static const List<String> _zohoProductOptions = [
    'Zoho CRM',
    'Zoho Books',
    'Zoho People',
    'Zoho Desk',
    'Zoho Projects',
    'Zoho Inventory',
    'Zoho Analytics',
    'Zoho Creator',
    'Zoho Flow',
    'Zoho Recruit',
    'Zoho Campaigns',
    'Zoho SalesIQ',
    'Zoho Survey',
    'Zoho Subscriptions',
    'Zoho Sign',
    'Zoho Cliq',
    'Zoho Mail',
    'Zoho WorkDrive',
    'Zoho Commerce',
    'Zoho Catalyst',
    'Others',
  ];

  @override
void initState() {
  super.initState();

  _selectedProjectId = widget.projectId;
  _selectedSprintId = widget.sprintId;
  _selectedEpicId = widget.epicId;
  
  if (widget.status != null && widget.status!.isNotEmpty) {
    _status = widget.status!;
  }

  debugPrint(
    'Preselected project: ${widget.projectNameSelected} (${widget.projectId})'
  );

  _loadInitialData();
}

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchUsers(),
      _fetchProjects(),
      if (widget.projectId != null) _fetchSprints(widget.projectId!),
      if (widget.projectId != null) _fetchEpics(widget.projectId!),
    ]);
  }

  Future<void> _fetchProjects() async { // projects here
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

  Future<void> _fetchSprints(String projectId) async {
    setState(() {
      _isSprintsLoading = true;
      _hasSprintsError = false;
      _sprints = [];
      _selectedSprintId = widget.sprintId;
    });
    try {
      _sprints = await ref
          .read(getSprintsRepositoryProvider)
          .fetchSprints(projectId: projectId);
    } catch (_) {
      _hasSprintsError = true;
      _sprints = [];
    } finally {
      if (mounted) setState(() => _isSprintsLoading = false);
    }
  }

  Future<void> _fetchEpics(String projectId) async {
    setState(() {
      _isEpicsLoading = true;
      _hasEpicsError = false;
      _epics = [];
      _selectedEpicId = widget.epicId;
    });
    try {
      final hierarchy = await ref
          .read(hierarchyRepositoryProvider)
          .fetchHierarchy(projectId: projectId);
      _epics = hierarchy.epics;
    } catch (_) {
      _hasEpicsError = true;
      _epics = [];
    } finally {
      if (mounted) setState(() => _isEpicsLoading = false);
    }
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isUsersLoading = true;
      _hasUsersError = false;
    });
    try {
      _users = await ref.read(fetchBadgeUsersRepositoryProvider).fetchUsers();
    } catch (_) {
      _hasUsersError = true;
      _users = [];
    } finally {
      if (mounted) setState(() => _isUsersLoading = false);
    }
  }

  Future<void> _createStory() async {
    final projectId = _selectedProjectId;
    final sprintId = _selectedSprintId;

    if (projectId == null || projectId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project')),
      );
      return;
    }

    if (sprintId == null || sprintId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sprint')),
      );
      return;
    }

    if (_selectedEpicId == null || _selectedEpicId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an epic')),
      );
      return;
    }

    final submitLoadingNotifier =
        ref.read(submitLoadingProvider(_loadingKey).notifier);
    submitLoadingNotifier.state = true;

    try {
      final repo = ref.read(createStoryRepositoryProvider);
      
      final finalSprintId = sprintId == 'BACKLOG' ? '' : sprintId;

      await repo.createStory(
        title: _titleController.text.trim(),
        projectId: projectId,
        sprintId: finalSprintId,
        description: _descriptionController.text.trim(),
        epicId: _selectedEpicId,
        assigneeId: _selectedAssigneeId,
        primaryOwnership: _selectedPrimaryOwnerId,
        secondaryOwnership: _selectedSecondaryOwnerId,
        status: _status,
        points: _points,
        priority: _priority,
        billingType: _billingType,
        requirementType: _requirementType,
        moduleName: _moduleNameController.text.trim(),
        groupName: _groupNameController.text.trim(),
        zohoProductName: _zohoProductName,
        fiRemarks: _fiRemarksController.text.trim(),
        clientRemarks: _clientRemarksController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story created successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final errorText = e.toString();
      debugPrint("error here");
      debugPrint(e.toString());
      final message = errorText.contains('do not have permission')
          ? 'Permission denied from server, please try again.'
          : 'Failed to create story. Please try again.';

      
      showErrorSnackBar(context, message);
    } finally {
      submitLoadingNotifier.state = false;
    }
  }

  List<DropdownMenuItem<String>> _userItems({String? excludeId}) {
    return _users
        .where((u) => u.userId != excludeId)
        .map((u) => DropdownMenuItem<String>(
              value: u.userId,
              child: Text(u.fullName),
            ))
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _groupNameController.dispose();
    _moduleNameController.dispose();
    _fiRemarksController.dispose();
    _clientRemarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final statusItems = _statusOptions
        .map((s) => DropdownMenuItem<String>(
              value: s['value']!,
              child: Text(s['label']!),
            ))
        .toList();

    final priorityItems = _priorityOptions
        .map((p) => DropdownMenuItem<String>(
              value: p['value']!,
              child: Text(p['label']!),
            ))
        .toList();

    final projectItems = [
      if (widget.projectId != null &&
          widget.projectNameSelected != null &&
          !_projects.any((p) => p.id == widget.projectId))
        DropdownMenuItem<String>(
          value: widget.projectId!,
          child: Text(widget.projectNameSelected!),
        ),

      ..._projects.map((p) => DropdownMenuItem<String>(
            value: p.id,
            child: Text(p.projectName),
          )),
    ];

    final sprintItems = [
      const DropdownMenuItem<String>(
        value: 'BACKLOG',
        child: Text('Backlog'),
      ),

      if (widget.sprintId != null &&
          widget.sprintId != 'BACKLOG' &&
          widget.sprintNameSelected != null &&
          !_sprints.any((s) => s.rowId == widget.sprintId))
        DropdownMenuItem<String>(
          value: widget.sprintId!,
          child: Text(widget.sprintNameSelected!),
        ),

      ..._sprints.map((s) => DropdownMenuItem<String>(
            value: s.rowId,
            child: Text(s.sprintName),
          )),
    ];

    final epicItems = _epics
        .map((e) => DropdownMenuItem<String>(
              value: e.id,
              child: Text(e.title),
            ))
        .toList();

    final assigneeItems = [
      const DropdownMenuItem<String>(
        value: '',
        child: Text('Unassigned'),
      ),
      ..._userItems(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Story',
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
                'Story Details',
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
                      // Title (required)
                      CustomInputField(
                        controller: _titleController,
                        hintText: 'Story Title',
                        labelText: 'Story Title',
                        prefixIcon: Icons.book_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter story title';
                          }
                          return null;
                        },
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
                      ),

                      const SizedBox(height: 20),

                      // Project (always shown, mandatory)
                      CustomDropDownField(
                        hintText: _isProjectsLoading
                            ? 'Loading projects...'
                            : _hasProjectsError
                                ? 'Failed to load projects'
                                : widget.projectNameSelected?? 'Select Project',
                        labelText: 'Project *',
                        prefixIcon: Icons.folder_outlined,
                        searchable: true,
                        searchHintText: 'Search project',
                        options: projectItems,
                        selectedOption: _selectedProjectId,
                        onChanged: projectItems.isEmpty
                            ? (_) {}
                            : (value) {
                                setState(() {
                                  _selectedProjectId = value;
                                  _selectedSprintId = null;
                                  _selectedEpicId = null;
                                  _sprints = [];
                                  _epics = [];
                                });
                                if (value != null && value.isNotEmpty) {
                                  _fetchSprints(value);
                                  _fetchEpics(value);
                                }
                              },
                      ),

                      const SizedBox(height: 20),

                      // Sprint (always shown, mandatory)
                      CustomDropDownField(
                        hintText: _selectedProjectId == null
                            ? 'Select project first'
                            : _isSprintsLoading
                                ? 'Loading sprints...'
                                : _hasSprintsError
                                    ? 'Failed to load sprints'
                                    : 'Select sprint',
                        labelText: 'Sprint *',
                        prefixIcon: Icons.directions_run_outlined,
                        searchable: true,
                        searchHintText: 'Search sprint',
                        options: sprintItems,
                        selectedOption: _selectedSprintId,
                        onChanged: sprintItems.isEmpty
                            ? (_) {}
                            : (value) {
                                setState(() {
                                  _selectedSprintId = value;
                                });
                              },
                      ),

                      const SizedBox(height: 20),

                      // Status
                      CustomDropDownField(
                        hintText: 'Select status',
                        labelText: 'Status',
                        prefixIcon: Icons.track_changes_outlined,
                        options: statusItems,
                        selectedOption: _status,
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Priority
                      CustomDropDownField(
                        hintText: 'Select priority',
                        labelText: 'Priority',
                        prefixIcon: Icons.flag_outlined,
                        options: priorityItems,
                        selectedOption: _priority,
                        onChanged: (val) {
                          if (val != null) setState(() => _priority = val);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Story Points
                      _buildPointsField(),

                      const SizedBox(height: 20),

                      // Epic (mandatory)
                      CustomDropDownField(
                        hintText: _selectedProjectId == null
                            ? 'Select project first'
                            : _isEpicsLoading
                                ? 'Loading epics...'
                                : _hasEpicsError
                                    ? 'Failed to load epics'
                                    : widget.epicName ?? 'Select epic',
                        labelText: 'Epic *',
                        prefixIcon: Icons.layers_outlined,
                        searchable: true,
                        searchHintText: 'Search epic',
                        options: epicItems,
                        selectedOption: _selectedEpicId,
                        onChanged: (val) {
                          setState(() => _selectedEpicId = val);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Assignee
                      CustomDropDownField(
                        hintText: _isUsersLoading
                            ? 'Loading users...'
                            : _hasUsersError
                                ? 'Failed to load users'
                                : 'Unassigned',
                        labelText: 'Assignee',
                        prefixIcon: Icons.person_outline,
                        searchable: true,
                        searchHintText: 'Search user',
                        options: assigneeItems,
                        selectedOption: _selectedAssigneeId ?? '',
                        onChanged: assigneeItems.isEmpty
                            ? (_) {}
                            : (val) {
                                setState(() =>
                                    _selectedAssigneeId = val == '' ? null : val);
                              },
                      ),

                      const SizedBox(height: 20),

                      // Group Name
                      CustomInputField(
                        controller: _groupNameController,
                        hintText: 'Group Name',
                        labelText: 'Group Name',
                        prefixIcon: Icons.group_outlined,
                      ),

                      const SizedBox(height: 20),

                      // Module Name
                      CustomInputField(
                        controller: _moduleNameController,
                        hintText: 'Module Name',
                        labelText: 'Module Name',
                        prefixIcon: Icons.view_module_outlined,
                      ),

                      const SizedBox(height: 20),

                      // Requirement Type
                      CustomDropDownField(
                        hintText: 'Select requirement type',
                        labelText: 'Requirement Type',
                        prefixIcon: Icons.list_alt_outlined,
                        options: _requirementTypeOptions
                            .map((r) => DropdownMenuItem<String>(
                                  value: r,
                                  child: Text(r),
                                ))
                            .toList(),
                        selectedOption: _requirementType,
                        onChanged: (val) =>
                            setState(() => _requirementType = val),
                      ),

                      const SizedBox(height: 20),

                      // Billing Type
                      CustomDropDownField(
                        hintText: 'Select billing type',
                        labelText: 'Billing Type',
                        prefixIcon: Icons.receipt_outlined,
                        options: _billingTypeOptions
                            .map((b) => DropdownMenuItem<String>(
                                  value: b,
                                  child: Text(b),
                                ))
                            .toList(),
                        selectedOption: _billingType,
                        onChanged: (val) => setState(() => _billingType = val),
                      ),

                      const SizedBox(height: 20),

                      // Zoho Product Name
                      CustomDropDownField(
                        hintText: 'Select Zoho product',
                        labelText: 'Zoho Product Name',
                        prefixIcon: Icons.inventory_2_outlined,
                        searchable: true,
                        searchHintText: 'Search Zoho product',
                        options: _zohoProductOptions
                            .map((z) => DropdownMenuItem<String>(
                                  value: z,
                                  child: Text(z),
                                ))
                            .toList(),
                        selectedOption: _zohoProductName,
                        onChanged: (val) =>
                            setState(() => _zohoProductName = val),
                      ),

                      const SizedBox(height: 20),

                      // Primary Ownership
                      CustomDropDownField(
                        hintText: _isUsersLoading
                            ? 'Loading users...'
                            : 'Select primary owner',
                        labelText: 'Primary Ownership',
                        prefixIcon: Icons.person_pin_outlined,
                        searchable: true,
                        searchHintText: 'Search user',
                        options: _userItems(excludeId: _selectedSecondaryOwnerId),
                        selectedOption: _selectedPrimaryOwnerId,
                        onChanged: _users.isEmpty
                            ? (_) {}
                            : (val) => setState(() => _selectedPrimaryOwnerId = val),
                      ),

                      const SizedBox(height: 20),

                      // Secondary Ownership
                      CustomDropDownField(
                        hintText: _isUsersLoading
                            ? 'Loading users...'
                            : 'Select secondary owner',
                        labelText: 'Secondary Ownership',
                        prefixIcon: Icons.person_pin_circle_outlined,
                        searchable: true,
                        searchHintText: 'Search user',
                        options: _userItems(excludeId: _selectedPrimaryOwnerId),
                        selectedOption: _selectedSecondaryOwnerId,
                        onChanged: _users.isEmpty
                            ? (_) {}
                            : (val) => setState(() => _selectedSecondaryOwnerId = val),
                      ),

                      const SizedBox(height: 20),

                      // FI Remarks
                      CustomInputField(
                        controller: _fiRemarksController,
                        hintText: 'FI Remarks',
                        isMultiline: true,
                        labelText: 'FI Remarks',
                        prefixIcon: Icons.comment_outlined,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 20),

                      // Client Remarks
                      CustomInputField(
                        controller: _clientRemarksController,
                        hintText: 'Client Remarks',
                        isMultiline: true,
                        labelText: 'Client Remarks',
                        prefixIcon: Icons.rate_review_outlined,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),

                      BottomTwoButtons(
                        loadingKey: _loadingKey,
                        button1Text: 'cancel',
                        button2Text: 'create story',
                        button1Function: () => Navigator.pop(context),
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            _createStory();
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

  Widget _buildPointsField() {
    final customColors = Theme.of(context).custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Story Points',
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.85),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: customColors.inputFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.stars_outlined,
                  color: Colors.grey.withValues(alpha: 0.85), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: _points.toString(),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: customColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) setState(() => _points = parsed);
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_points > 0) setState(() => _points--);
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.grey.withValues(alpha: 0.85),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                '$_points',
                style: TextStyle(
                  color: customColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => setState(() => _points++),
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.grey.withValues(alpha: 0.85),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
