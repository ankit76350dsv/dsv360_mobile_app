import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/dashboard/view/pages/AppDrawer.dart';
import 'package:dsv360/features/sprints/model/sprints_model.dart';
import 'package:dsv360/features/sprints/repositories/get_sprints_repository.dart';
import 'package:dsv360/features/sprints/repositories/heirarchy_repository.dart';
import 'package:dsv360/features/sprints/repositories/update_story_status_repository.dart';
import 'package:dsv360/features/sprints/repositories/complete_sprint_repository.dart';
import 'package:dsv360/features/sprints/view/pages/create_epic_page.dart';
import 'package:dsv360/features/sprints/view/pages/create_release_page.dart';
import 'package:dsv360/features/sprints/view/pages/create_sprint_page.dart';
import 'package:dsv360/features/sprints/view/pages/backlog_page.dart';
import 'package:dsv360/features/sprints/view/pages/create_story_page.dart';
import 'package:dsv360/features/sprints/repositories/get_projects_repository.dart' as sprints_projects;
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sprint_story.dart';
import '../widgets/board_view.dart';
import '../widgets/timeline_view.dart';

final projectListProvider = FutureProvider((ref) async {
  final repo = ref.read(sprints_projects.projectRepositoryProvider);
  return repo.fetchProjects();
});

final sprintListProvider = FutureProvider.family<List<SprintModel>, String>((
  ref,
  projectId,
) async {
  final repo = ref.read(getSprintsRepositoryProvider);
  return repo.fetchSprints(projectId: projectId);
});

final hierarchyProvider =
    FutureProvider.family<
      List<SprintStory>,
      ({String projectId, String? sprintId})
    >((ref, args) async {
      final repo = ref.read(hierarchyRepositoryProvider);
      final hierarchy = await repo.fetchHierarchy(projectId: args.projectId);
      return hierarchy.stories
          .where((s) => args.sprintId == null || s.sprintId == args.sprintId)
          .map((s) {
            // Calculate task counts for this story
            final tasksForStory = hierarchy.tasks
                .where((t) => t.storyId == s.id)
                .toList();
            final totalTasksCount = tasksForStory.length;
            final completedTasksCount = tasksForStory
                .where((t) => t.status.toLowerCase() == 'closed')
                .length;

            return SprintStory(
              id: s.id,
              title: s.title,
              completedPoints: 0,
              totalPoints: s.points,
              memberAvatars: [],
              storyLabel: 'Story',
              storyPoints: s.points,
              columnId: s.status.toLowerCase().replaceAll(' ', '_'),
              status: s.status,
              totalTasks: totalTasksCount,
              completedTasks: completedTasksCount,
              assigneeId: s.assigneeId,
            );
          })
          .toList();
    });

final rawHierarchyProvider =
    FutureProvider.family<dynamic, String>((ref, projectId) async {
  final repo = ref.read(hierarchyRepositoryProvider);
  return repo.fetchHierarchy(projectId: projectId);
});

// ── Main Widget ─────────────────────────────────────────────────────────────

class SprintsScreen extends ConsumerStatefulWidget {
  final String? projectId;
  final String? projectName;

  const SprintsScreen({super.key, this.projectId, this.projectName});

  @override
  ConsumerState<SprintsScreen> createState() => _SprintsScreenState();
}

class _SprintsScreenState extends ConsumerState<SprintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _selectedProjectName;
  String? _selectedProjectId;

  String? _selectedSprintStatus;

  String? _selectedSprintName;
  String? _selectedSprintId;



  bool _isRefreshingData = false;

  void _autoSelectFirstProject(List<dynamic> projects) {
    if (_selectedProjectId != null || projects.isEmpty) return;

    final firstProject = projects.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedProjectId != null) return;
      setState(() {
        _selectedProjectName = firstProject.projectName;
        _selectedProjectId = firstProject.id;
      });
    });
  }

  void _autoSelectFirstSprint(List<SprintModel> sprints) {
    if (_selectedProjectId == null || _selectedProjectId!.isEmpty) return;
    if (_selectedSprintId != null || sprints.isEmpty) return;

    final firstSprint = sprints.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedSprintId != null) return;
      setState(() {
        _selectedSprintName = firstSprint.sprintName;
        _selectedSprintId = firstSprint.rowId;
        _selectedSprintStatus = firstSprint.status;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _totalPoints(List<SprintStory> stories) =>
      stories.fold(0, (sum, s) => sum + s.storyPoints);

  int _completedPoints(List<SprintStory> stories) => stories
      .where((s) => s.columnId == 'closed')
      .fold(0, (sum, s) => sum + s.storyPoints);

  int _totalStories(List<SprintStory> stories) => stories.length;

  int _completedStories(List<SprintStory> stories) => stories
      .where((s) => s.columnId == 'closed' || s.columnId == 'uat_approved')
      .length;

  double _progress(List<SprintStory> stories) {
    final total = _totalPoints(stories);
    return total == 0 ? 0.0 : _completedPoints(stories) / total;
  }

  static const _columnToApiStatus = {//here
    'not_started': 'NOT_STARTED',
    'wip': 'WIP',
    'pending_from_zoho': 'PENDING_FROM_ZOHO',
    'pending_from_client': 'PENDING_FROM_CLIENT',
    'released_for_uat': 'RELEASED_FOR_UAT',
    'uat_approved_by_client': 'UAT_APPROVED_BY_CLIENT',
    'under_internal_testing': 'UNDER_INTERNAL_TESTING',
    'closed': 'CLOSED',
  };

  void _moveStory(SprintStory story, String newColumnId) {
    final previousColumnId = story.columnId;
    setState(() {
      story.columnId = newColumnId;
    });

    final apiStatus = _columnToApiStatus[newColumnId];
    if (apiStatus == null) return;

    ref
        .read(updateStoryStatusRepositoryProvider)
        .updateStatus(storyId: story.id, status: apiStatus)
        .catchError((e) {
      debugPrint('Failed to update story status: $e');
      if (mounted) {
        setState(() {
          story.columnId = previousColumnId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    });
  }

  Future<void> _showProjectSelector({
    required BuildContext context,
    required List<dynamic> projects,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color greyBorder,
    required Color primary,
  }) async {
    String query = '';

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        final maxHeight = MediaQuery.of(dialogContext).size.height * 0.6;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              final filteredProjects = projects.where((p) {
                final name = (p.projectName ?? '').toString().toLowerCase();
                return name.contains(query.toLowerCase());
              }).toList();

              return Container(
                constraints: BoxConstraints(maxHeight: maxHeight),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: greyBorder, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) {
                          setDialogState(() {
                            query = value;
                          });
                        },
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search project...',
                          hintStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: cardBg,
                          prefixIcon: Icon(
                            Icons.search,
                            color: textSecondary,
                            size: 18,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: greyBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: greyBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: greyBorder),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: filteredProjects.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No projects found',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              itemCount: filteredProjects.length,
                              itemBuilder: (context, index) {
                                final project = filteredProjects[index];
                                final isSelected =
                                    _selectedProjectName == project.projectName;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    setState(() {
                                      _selectedProjectName =
                                          project.projectName;
                                      _selectedProjectId = project.id;
                                      _selectedSprintName = null;
                                      _selectedSprintId = null;
                                    });
                                    debugPrint(
                                      'Selected Project: $_selectedProjectName ($_selectedProjectId)',
                                    );
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isSelected
                                          ? primary.withValues(alpha: 0.12)
                                          : Colors.transparent,
                                    ),
                                    child: Text(
                                      project.projectName,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showSprintSelector({
    required BuildContext context,
    required List<SprintModel> sprints,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color greyBorder,
    required Color primary,
  }) async {
    String query = '';

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        final maxHeight = MediaQuery.of(dialogContext).size.height * 0.6;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              final filteredSprints = sprints.where((s) {
                final name = (s.sprintName).toLowerCase();
                return name.contains(query.toLowerCase());
              }).toList();

              return Container(
                constraints: BoxConstraints(maxHeight: maxHeight),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: greyBorder, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) {
                          setDialogState(() {
                            query = value;
                          });
                        },
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search sprint...',
                          hintStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: cardBg,
                          prefixIcon: Icon(
                            Icons.search,
                            color: textSecondary,
                            size: 18,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: greyBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: greyBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: greyBorder),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: filteredSprints.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No sprints found',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              itemCount: filteredSprints.length,
                              itemBuilder: (context, index) {
                                final sprint = filteredSprints[index];
                                final isSelected =
                                    _selectedSprintName == sprint.sprintName;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    setState(() {
                                      _selectedSprintName = sprint.sprintName;
                                      _selectedSprintId = sprint.rowId;
                                      _selectedSprintStatus = sprint.status;
                                    });
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isSelected
                                          ? primary.withValues(alpha: 0.12)
                                          : Colors.transparent,
                                    ),
                                    child: Text(
                                      sprint.sprintName,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingSprint(Color cardBg, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: cardBg),
      child: Text(
        'Loading...',
        style: TextStyle(color: textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _buildErrorSprint(Color textSecondary) {
    return Text('Error', style: TextStyle(color: textSecondary));
  }

  Widget _buildDisabledSprintDropdown(
    Color cardBg,
    Color border,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Select Project first',
        style: TextStyle(color: textSecondary),
      ),
    );
  }

 Future<void> _onRefresh() async {
  try {
    final _ = await ref.refresh(projectListProvider.future);

    if (_selectedProjectId != null && _selectedProjectId!.isNotEmpty) {

      // get fresh sprint list
      final refreshedSprints = await ref.refresh(
  sprintListProvider(_selectedProjectId!).future,
);

if (_selectedSprintId != null) {
  try {
    final selectedSprint = refreshedSprints.firstWhere(
      (s) => s.rowId == _selectedSprintId,
    );

    setState(() {
      _selectedSprintStatus = selectedSprint.status;
      _selectedSprintName = selectedSprint.sprintName;
    });
  } catch (_) {}
}
      // update selected sprint status from fresh data
      if (_selectedSprintId != null) {
        try {
          final selectedSprint = refreshedSprints.firstWhere(
            (s) => s.rowId == _selectedSprintId,
          );

          if (mounted) {
            setState(() {
              _selectedSprintStatus = selectedSprint.status;
              _selectedSprintName = selectedSprint.sprintName;
            });
          }
        } catch (_) {}
      }

      final _ = await ref.refresh(
        hierarchyProvider((
          projectId: _selectedProjectId!,
          sprintId: _selectedSprintId,
        )).future,
      );
    }
  } catch (e) {
    debugPrint('Refresh error: $e');
  }
}

  Future<void> _showCarryOverSprintSelector({
    required BuildContext context,
    required List<SprintModel> sprints,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color greyBorder,
    required Color primary,
  }) async {
    String? selectedCarryOverSprintId;
    String query = '';

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        final maxHeight = MediaQuery.of(dialogContext).size.height * 0.6;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              final filteredSprints = sprints.where((s) {
                final name = (s.sprintName).toLowerCase();
                return name.contains(query.toLowerCase()) && s.rowId != _selectedSprintId;
              }).toList();

              return Container(
                constraints: BoxConstraints(maxHeight: maxHeight),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: greyBorder, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Text(
                        'Select Sprint to Carry Over Stories',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) {
                          setDialogState(() {
                            query = value;
                          });
                        },
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search sprint...',
                          hintStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: cardBg,
                          prefixIcon: Icon(
                            Icons.search,
                            color: textSecondary,
                            size: 18,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greyBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greyBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greyBorder),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: filteredSprints.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No sprints found',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              itemCount: filteredSprints.length,
                              itemBuilder: (context, index) {
                                final sprint = filteredSprints[index];
                                final isSelected =
                                    selectedCarryOverSprintId == sprint.rowId;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    setDialogState(() {
                                      selectedCarryOverSprintId = sprint.rowId;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isSelected
                                          ? primary.withValues(alpha: 0.12)
                                          : Colors.transparent,
                                      border: isSelected
                                          ? Border.all(color: primary, width: 1)
                                          : null,
                                    ),
                                    child: Text(
                                      sprint.sprintName,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: selectedCarryOverSprintId == null
                                ? null
                                : () async {
                                    Navigator.pop(dialogContext);
                                    await _completeSprintProcess(
                                      selectedCarryOverSprintId!,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              disabledBackgroundColor:
                                  primary.withValues(alpha: 0.5),
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _completeSprintProcess(String carryOverSprintId) async {
    if (_selectedSprintId == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completing sprint...'),
          duration: Duration(seconds: 2),
        ),
      );

      await ref
          .read(completeSprintRepositoryProvider)
          .completeSprint(
            sprintId: _selectedSprintId!,
            carryOverSprintId: carryOverSprintId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sprint completed successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Refresh data after completing sprint
        await _onRefresh();
      }
    } catch (e) {
      debugPrint('Error completing sprint: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing sprint: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, mode, _) {
        final customColors = Theme.of(context).custom;
        final isDark = mode == ThemeMode.dark;

        final background =
            customColors.background ??
            (isDark ? AppColorsDark.background : AppColorsLight.background);
        final cardBg =
            customColors.cardBackground ??
            (isDark
                ? AppColorsDark.cardBackground
                : AppColorsLight.cardBackground);
        final textPrimary =
            customColors.textPrimary ??
            (isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary);
        final textSecondary =
            customColors.textSecondary ??
            (isDark
                ? AppColorsDark.textSecondary
                : AppColorsLight.textSecondary);
        final greyBorder =
            customColors.greyBorder ??
            (isDark ? AppColorsDark.greyBorder : AppColorsLight.greyBorder);
        final primary = customColors.primary ?? AppColorsDark.primary;
        final tabbarBg =
            customColors.tabbarBackground ??
            (isDark
                ? AppColorsDark.tabbarBackground
                : AppColorsLight.tabbarBackground);
        final activeUser = ref.watch(activeUserRepositoryProvider);
        final roleName = (activeUser?.roleName ?? '').toLowerCase().trim();
        final canManageSprints =
          roleName == 'admin' || roleName == 'super admin';

        return Scaffold(
          drawer: const AppDrawer(),
          backgroundColor: background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Bar ──
                  TopBar(
                    title: 'Sprints',
                    onBack: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    onInfoTap: () async {
                      if (_isRefreshingData) return;

                      setState(() => _isRefreshingData = true);
                      try {
                        final _ = await ref.refresh(projectListProvider.future);
                        if (_selectedProjectId != null &&
                            _selectedProjectId!.isNotEmpty) {
                          final _ = await ref.refresh(
                            sprintListProvider(_selectedProjectId!).future,
                          );
                          final _ = await ref.refresh(
                            hierarchyProvider((
                              projectId: _selectedProjectId!,
                              sprintId: _selectedSprintId,
                            )).future,
                          );
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data refreshed successfully'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('Refresh error: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Refresh failed: $e')),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isRefreshingData = false);
                        }
                      }
                    },
                    actionIcon: Icons.refresh_rounded,
                  ),

                  // ── Project selector + Complete button ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'PROJECT',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final projectsAsync = ref.watch(
                                projectListProvider,
                              );

                              return projectsAsync.when(
                                loading: () => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: greyBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Loading...',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                                error: (error, _) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    'Error loading projects',
                                    style: TextStyle(color: textSecondary),
                                  ),
                                ),

                                data: (projects) {
                                  _autoSelectFirstProject(projects);

                                  return SizedBox(
                                    height: 35,
                                    child: GestureDetector(
                                      onTap: () => _showProjectSelector(
                                        context: context,
                                        projects: projects,
                                        cardBg: cardBg,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        greyBorder: greyBorder,
                                        primary: primary,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cardBg,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: greyBorder,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedProjectName ??
                                                    'Select Project',
                                                style: TextStyle(
                                                  color:
                                                      _selectedProjectName ==
                                                          null
                                                      ? textSecondary
                                                      : textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_down,
                                              color: textSecondary,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (canManageSprints && _selectedSprintId != null)
                          GestureDetector(
                            onTap: _selectedSprintStatus == 'ACTIVE'
                                ? () async {
                                    final isConfirmed =
                                        await showWarningDialogueBox(
                                          context: context,
                                          title: "Complete Sprint",
                                          subtitle:
                                              "Are you sure you want to mark \nSprint : $_selectedSprintName\n as Complete?",
                                          primaryText: "Complete",
                                        );

                                    if (isConfirmed == true) {
                                      // Get all sprints to show in carry-over selection
                                      if (_selectedProjectId != null &&
                                          _selectedProjectId!.isNotEmpty) {
                                        final sprints = await ref
                                            .read(getSprintsRepositoryProvider)
                                            .fetchSprints(
                                              projectId: _selectedProjectId!,
                                            );

                                        if (mounted) {
                                          await _showCarryOverSprintSelector(
                                            context: context,
                                            sprints: sprints,
                                            cardBg: cardBg,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            greyBorder: greyBorder,
                                            primary: primary,
                                          );
                                        }
                                      }
                                    }
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedSprintStatus == 'ACTIVE'
                                      ? primary
                                      : primary.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _selectedSprintStatus == 'ACTIVE'
                                    ? 'Complete Sprint'
                                    : 'Completed',
                                style: TextStyle(
                                  color: _selectedSprintStatus == 'ACTIVE'
                                      ? primary
                                      : primary.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Cycle status + Sprint dropdown + Sprint/Issue buttons ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // CYCLE label
                          Text(
                            'CYCLE',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Active badge or No Sprint message
                          if (_selectedSprintId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                               (_selectedSprintStatus ?? 'Active'),
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            )
                          else
                            Text(
                              ': ',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(width: 6),
                          // Sprint dropdown
                          Consumer(
                            builder: (context, ref, child) {
                              if (_selectedProjectId == null ||
                                  _selectedProjectId!.isEmpty) {
                                return _buildDisabledSprintDropdown(
                                  cardBg,
                                  greyBorder,
                                  textSecondary,
                                );
                              }

                              final sprintsAsync = ref.watch(
                                sprintListProvider(_selectedProjectId!),
                              );

                              return sprintsAsync.when(
                                loading: () =>
                                    _buildLoadingSprint(cardBg, textSecondary),
                                error: (_, __) =>
                                    _buildErrorSprint(textSecondary),
                                data: (sprints) {
                                  _autoSelectFirstSprint(sprints);

                                  if (sprints.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        '  No sprint        ',
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }

                                  return GestureDetector(
                                    onTap: () => _showSprintSelector(
                                      context: context,
                                      sprints: sprints,
                                      cardBg: cardBg,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                      greyBorder: greyBorder,
                                      primary: primary,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: greyBorder,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _selectedSprintName ??
                                                'Select Sprint',
                                            style: TextStyle(
                                              color: _selectedSprintName == null
                                                  ? textSecondary
                                                  : textPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: textSecondary,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          if (canManageSprints) ...[
                            // + SPRINT button
                            GestureDetector(
                              onTap: () {
                                if (_selectedProjectId == null ||
                                    _selectedProjectId!.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a project first',
                                      ),
                                      elevation: 5,
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateSprintPage(
                                      projectId: _selectedProjectId!,
                                      projectName: _selectedProjectName!,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: greyBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: primary, size: 13),
                                    const SizedBox(width: 2),
                                    Text(
                                      'SPRINT',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // + Release button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateReleasePage(
                                      projectId: _selectedProjectId,
                                      projectName: _selectedProjectName,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: greyBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: primary, size: 13),
                                    const SizedBox(width: 2),
                                    Text(
                                      'RELEASE',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // + EPIC button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateEpicPage(
                                      projectId:
                                          _selectedProjectId ??
                                          widget.projectId,
                                      projectName:
                                          _selectedProjectName ??
                                          widget.projectName,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: greyBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: primary, size: 13),
                                    const SizedBox(width: 2),
                                    Text(
                                      'EPIC',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // + ISSUE button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateStoryPage(
                                      projectId:
                                          _selectedProjectId ??
                                          widget.projectId,
                                      sprintId: _selectedSprintId ?? '',
                                      sprintNameSelected: _selectedSprintName,
                                      projectNameSelected:
                                          _selectedProjectName,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: greyBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: primary, size: 13),
                                    const SizedBox(width: 2),
                                    Text(
                                      'STORY',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Tab bar: Board / Backlog / Timeline ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tabbarBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: textPrimary,
                        unselectedLabelColor: textSecondary,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        indicator: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.3 : 0.1,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Board'),
                          Tab(text: 'Backlog'),
                          Tab(text: 'Timeline'),
                        ],
                      ),
                    ),
                  ),

                  // ── Tab content ──
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // Board tab
                        Builder(
                          builder: (context) {
                            final projectId =
                                _selectedProjectId ?? widget.projectId;
                            if (projectId == null || projectId.isEmpty) {
                              return Center(
                                child: Text(
                                  'Select a project to view board',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }
                            final hierarchyAsync = ref.watch(
                              hierarchyProvider((
                                projectId: projectId,
                                sprintId: _selectedSprintId,
                              )),
                            );
                            final sprintsAsync = ref.watch(
                              sprintListProvider(projectId),
                            );
                            return hierarchyAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, _) => Center(
                                child: Text(
                                  'Error loading stories: $e',
                                  style: TextStyle(color: textSecondary),
                                ),
                              ),
                              data: (stories) {
                                final visibleStories = canManageSprints
                                    ? stories
                                    : stories
                                        .where((s) =>
                                            s.assigneeId ==
                                            activeUser?.userId)
                                        .toList();
                                String? sprintEndDate;
                                if (_selectedSprintId != null) {
                                  sprintsAsync.whenData((sprints) {
                                    try {
                                      final selectedSprint = sprints
                                          .firstWhere(
                                            (s) => s.rowId == _selectedSprintId,
                                          );
                                      sprintEndDate = selectedSprint.endDate;
                                    } catch (e) {
                                      // Sprint not found
                                    }
                                  });
                                }
                                return BoardView(
                                  stories: visibleStories,
                                  onMove: _moveStory,
                                  isDark: isDark,
                                  customColors: customColors,
                                  cardBg: cardBg,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  greyBorder: greyBorder,
                                  primary: primary,
                                  progress: _progress(stories),
                                  completedPoints: _completedPoints(stories),
                                  totalPoints: _totalPoints(stories),
                                  completedStories: _completedStories(stories),
                                  totalStories: _totalStories(stories),
                                  projectId: projectId,
                                  projectName:
                                      _selectedProjectName ??
                                      widget.projectName,
                                  sprintId: _selectedSprintId,
                                  sprintName: _selectedSprintName,
                                  sprintEndDate: sprintEndDate,
                                );
                              },
                            );
                          },
                        ),
                        // Backlog tab
                        Builder(
                          builder: (context) {
                            final projectId =
                                _selectedProjectId ?? widget.projectId;
                            if (projectId == null || projectId.isEmpty) {
                              return Center(
                                child: Text(
                                  'Select a project to view backlog',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }
                            return BacklogPage(
                              projectId: projectId,
                              projectName:
                                  _selectedProjectName ?? widget.projectName,
                            );
                          },
                        ),
                        // Timeline tab
                        Builder(
                          builder: (context) {
                            final projectId =
                                _selectedProjectId ?? widget.projectId;
                            if (projectId == null || projectId.isEmpty) {
                              return Center(
                                child: Text(
                                  'Select a project to view timeline',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }
                            final rawAsync = ref.watch(
                              rawHierarchyProvider(projectId),
                            );
                            final sprintsAsync =
                                ref.watch(sprintListProvider(projectId));
                            return rawAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, _) => Center(
                                child: Text(
                                  'Error loading timeline: $e',
                                  style: TextStyle(color: textSecondary),
                                ),
                              ),
                              data: (hierarchy) {
                                String? sprintStart;
                                String? sprintEnd;
                                sprintsAsync.whenData((sprints) {
                                  try {
                                    final s = sprints.firstWhere(
                                      (s) => s.rowId == _selectedSprintId,
                                    );
                                    sprintStart = s.startDate;
                                    sprintEnd = s.endDate;
                                  } catch (_) {}
                                });
                                return TimelineView(
                                  hierarchy: hierarchy,
                                  sprintId: _selectedSprintId,
                                  isDark: isDark,
                                  cardBg: cardBg,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  greyBorder: greyBorder,
                                  primary: primary,
                                  sprintStartDate: sprintStart,
                                  sprintEndDate: sprintEnd,
                                  sprintName: _selectedSprintName,
                                  canManageSprints: canManageSprints,
                                  currentUserId: activeUser?.userId,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
