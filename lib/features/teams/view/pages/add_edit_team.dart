import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/teams/viewmodel/teams_provider.dart';
import 'package:dsv360/core/constants/active_user_repository.dart';

class AddEditTeamPage extends ConsumerStatefulWidget {
  final String? teamId;
  final String? teamName;
  final String? reportingManager;
  final String? reportingManagerId;

  const AddEditTeamPage({
    super.key,
    this.teamId,
    this.teamName,
    this.reportingManager,
    this.reportingManagerId,
  });

  @override
  ConsumerState<AddEditTeamPage> createState() => _AddEditTeamPageState();
}

class _AddEditTeamPageState extends ConsumerState<AddEditTeamPage> {
  final _formKey = GlobalKey<FormState>();

  late bool isEditing;
  late String _originalTeamName;
  late String? _originalReportingManagerId;
  final TextEditingController _teamNameController = TextEditingController();

  // Always drive the dropdown by ID; name is derived from the managers list
  String? _selectedReportingManagerId;

  final String bottomTwoButtonsLoadingKey = 'add_edit_team_key';

  @override
  void initState() {
    super.initState();
    isEditing = widget.teamName != null;

    if (isEditing) {
      _teamNameController.text = widget.teamName!;
      _originalTeamName = widget.teamName!;
      // FIX 1: Properly initialise selected ID so the dropdown pre-fills on edit
      _selectedReportingManagerId = widget.reportingManagerId;
      _originalReportingManagerId = widget.reportingManagerId;
    } else {
      _originalTeamName = '';
      _originalReportingManagerId = null;
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  /// Handle team creation or update
  Future<void> _handleTeamSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedReportingManagerId == null ||
        _selectedReportingManagerId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reporting manager')),
      );
      return;
    }

    // If editing and nothing changed, just go back
    if (isEditing &&
        _teamNameController.text.trim() == _originalTeamName &&
        _selectedReportingManagerId == _originalReportingManagerId) {
      Navigator.pop(context);
      return;
    }

    ref
        .read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier)
        .state = true;

    try {
      final activeUser = ref.read(activeUserRepositoryProvider);
      if (activeUser == null || activeUser.zaaid == null) {
        throw Exception('User session expired. Please log in again.');
      }

      final managers = await ref.read(reportingManagersProvider.future);

      final selectedManager = managers.firstWhere(
        (m) => m.userId == _selectedReportingManagerId,
        orElse: () =>
            throw Exception('Selected manager not found. Please choose another.'),
      );

      final teamNotifier = ref.read(teamNotifierProvider.notifier);

      final team = isEditing
          ? await teamNotifier.updateTeam(
            teamId: widget.teamId ?? '',
              teamName: _teamNameController.text.trim(),
              teamReportingManagerId: selectedManager.userId,
              teamReportingManager: selectedManager.fullName,
              teamReportingManagerProfile: selectedManager.profilePic,
              orgId: activeUser.zaaid!,
            )
          : await teamNotifier.createTeam(
              teamName: _teamNameController.text.trim(),
              teamReportingManagerId: selectedManager.userId,
              teamReportingManager: selectedManager.fullName,
              teamReportingManagerProfile: selectedManager.profilePic,
              orgId: activeUser.zaaid!,
            );

      if (!mounted) return;

      ref
          .read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier)
          .state = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Team updated successfully!'
              : 'Team created successfully!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, {
        'teamName': team.teamName,
        'reportingManager': team.teamReportingManager,
        'teamId': team.rowId,
        'success': true,
      });
    } catch (e) {
      // FIX 3: Simple, clean error handling — no Dio-specific if/else ladder
      if (!mounted) return;

      ref
          .read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier)
          .state = false;

      // Strip the "Exception: " prefix Flutter adds so the message stays clean
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('❌ Error in _handleTeamSubmit: $e');
    }
  }

  /// Build reporting manager dropdown with API-fetched data
  Widget _buildReportingManagerDropdown(
      BuildContext context, ColorScheme colors) {
    return Consumer(
      builder: (context, ref, child) {
        final reportingManagersAsync = ref.watch(reportingManagersProvider);

        return reportingManagersAsync.when(
          data: (managers) {
            final menuItems = managers
                .map(
                  (employee) => DropdownMenuItem<String>(
                    value: employee.userId,
                    child: Text(employee.fullName),
                  ),
                )
                .toList();

            // FIX 1 & 2: Always derive the display name from the managers list
            // using the current selected ID. This handles:
            //   - Pre-filling the name on edit page open
            //   - Always showing name (never raw ID) after any selection
            final displayName = _selectedReportingManagerId != null
                ? managers
                    .where((m) => m.userId == _selectedReportingManagerId)
                    .map((m) => m.fullName)
                    .firstOrNull
                : null;

            return CustomDropDownField(
              hintText: 'Reporting Manager',
              labelText: 'Reporting Manager',
              prefixIcon: Icons.person_search,
              selectedOption: displayName,
              searchable: true,
              searchHintText: 'Search reporting manager',
              options: menuItems,
              onChanged: (value) {
                // FIX 2: Only store the ID; display name is always derived above
                setState(() {
                  _selectedReportingManagerId = value;
                });
              },
            );
          },
          loading: () => CustomDropDownField(
            hintText: 'Reporting Manager',
            labelText: 'Reporting Manager',
            prefixIcon: Icons.person_search,
            selectedOption: null,
            searchable: false,
            options: const [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Loading managers...'),
              ),
            ],
            onChanged: (_) {},
          ),
          error: (error, _) {
            debugPrint('❌ Error loading reporting managers: $error');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Failed to load managers. Please go back and try again.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(height: 8),
                CustomDropDownField(
                  hintText: 'Reporting Manager',
                  labelText: 'Reporting Manager',
                  prefixIcon: Icons.person_search,
                  selectedOption: null,
                  searchable: false,
                  options: const [],
                  onChanged: (_) {},
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        toolbarHeight: 35.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Team' : 'Add New Team',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text(
                'Team Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
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
                        controller: _teamNameController,
                        hintText: 'Team Name',
                        labelText: 'Team Name',
                        prefixIcon: Icons.groups_2_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter team name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildReportingManagerDropdown(context, colors),
                      const SizedBox(height: 32),
                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: 'Cancel',
                        button2Text: isEditing ? 'Save Changes' : 'Add Team',
                        button1Function: () => Navigator.pop(context),
                        button2Function: _handleTeamSubmit,
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