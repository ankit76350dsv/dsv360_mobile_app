import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/dashboard/view/widgets/AppDrawer.dart';
import 'package:dsv360/features/sprints/model/sprints_model.dart';
import 'package:dsv360/features/sprints/viewmodel/sprint_viewmodel.dart';
import 'package:dsv360/features/sprints/viewmodel/hierarchy_viewmodel.dart';
import 'package:dsv360/features/sprints/viewmodel/story_viewmodel.dart';
import 'package:dsv360/features/sprints/viewmodel/sprints_project_viewmodel.dart'
    as sprints_projects_vm;
import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/core/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sprint_story.dart';
import '../widgets/sprint_project_selector.dart';
import '../widgets/sprint_cycle_bar.dart';
import '../widgets/sprint_tab_bar.dart';
import '../widgets/sprint_board_tab.dart';
import '../widgets/sprint_backlog_tab.dart';
import '../widgets/sprint_timeline_tab.dart';
import '../widgets/sprint_selector_dialog.dart';
import '../widgets/sprint_carry_over_dialog.dart';

final projectListProvider = FutureProvider((ref) async {
  final repo = ref.read(sprints_projects_vm.projectRepositoryProvider);
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
              priority: s.priority,
            );
          })
          .toList();
    });

final rawHierarchyProvider = FutureProvider.family<dynamic, String>((
  ref,
  projectId,
) async {
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

  bool _hasLoadedPersistedSelection = false;

  bool _isRefreshingData = false;

  static const _selectedProjectIdKey = 'sprints.selected_project_id';
  static const _selectedProjectNameKey = 'sprints.selected_project_name';
  static const _selectedSprintIdKey = 'sprints.selected_sprint_id';
  static const _selectedSprintNameKey = 'sprints.selected_sprint_name';
  static const _selectedSprintStatusKey = 'sprints.selected_sprint_status';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPersistedSelection();
  }

  Future<void> _loadPersistedSelection() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    String? normalize(String? value) =>
        value == null || value.isEmpty ? null : value;

    setState(() {
      _selectedProjectId = normalize(prefs.getString(_selectedProjectIdKey));
      _selectedProjectName = normalize(
        prefs.getString(_selectedProjectNameKey),
      );
      _selectedSprintId = normalize(prefs.getString(_selectedSprintIdKey));
      _selectedSprintName = normalize(prefs.getString(_selectedSprintNameKey));
      _selectedSprintStatus = normalize(
        prefs.getString(_selectedSprintStatusKey),
      );
      _hasLoadedPersistedSelection = true;
    });
  }

  Future<void> _saveSelectionToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedProjectIdKey, _selectedProjectId ?? '');
    await prefs.setString(_selectedProjectNameKey, _selectedProjectName ?? '');
    await prefs.setString(_selectedSprintIdKey, _selectedSprintId ?? '');
    await prefs.setString(_selectedSprintNameKey, _selectedSprintName ?? '');
    await prefs.setString(
      _selectedSprintStatusKey,
      _selectedSprintStatus ?? '',
    );
  }

  void _persistSelection() {
    unawaited(_saveSelectionToPrefs());
  }

  dynamic _findProjectById(List<dynamic> projects, String? projectId) {
    if (projectId == null || projectId.isEmpty) return null;
    for (final project in projects) {
      if (project.id == projectId) return project;
    }
    return null;
  }

  SprintModel? _findSprintById(List<SprintModel> sprints, String? sprintId) {
    if (sprintId == null || sprintId.isEmpty) return null;
    for (final sprint in sprints) {
      if (sprint.rowId == sprintId) return sprint;
    }
    return null;
  }

  void _syncProjectSelection(List<dynamic> projects) {
    if (!_hasLoadedPersistedSelection || projects.isEmpty) return;

    final validProject = _findProjectById(projects, _selectedProjectId);
    final fallbackProject = _findProjectById(projects, widget.projectId);
    final nextProject = validProject ?? fallbackProject ?? projects.first;

    final nextProjectId = nextProject.id;
    final nextProjectName = nextProject.projectName;
    final projectIdChanged = _selectedProjectId != nextProjectId;
    final projectNameChanged = _selectedProjectName != nextProjectName;
    final shouldUpdateProject = projectIdChanged || projectNameChanged;

    if (!shouldUpdateProject) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedProjectId = nextProjectId;
        _selectedProjectName = nextProjectName;
        if (projectIdChanged) {
          _selectedSprintId = null;
          _selectedSprintName = null;
          _selectedSprintStatus = null;
        }
      });
      _persistSelection();
    });
  }

  void _syncSprintSelection(List<SprintModel> sprints) {
    if (!_hasLoadedPersistedSelection) return;

    if (sprints.isEmpty) {
      if (_selectedSprintId == null &&
          _selectedSprintName == null &&
          _selectedSprintStatus == null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedSprintId = null;
          _selectedSprintName = null;
          _selectedSprintStatus = null;
        });
        _persistSelection();
      });
      return;
    }

    final validSprint = _findSprintById(sprints, _selectedSprintId);
    final nextSprint = validSprint ?? sprints.first;
    final shouldUpdateSprint =
        _selectedSprintId != nextSprint.rowId ||
        _selectedSprintName != nextSprint.sprintName ||
        _selectedSprintStatus != nextSprint.status;

    if (!shouldUpdateSprint) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedSprintId = nextSprint.rowId;
        _selectedSprintName = nextSprint.sprintName;
        _selectedSprintStatus = nextSprint.status;
      });
      _persistSelection();
    });
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

  static const _columnToApiStatus = {
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
            showErrorSnackBar(
              context,
              'Failed to update status. Please try again.',
            );
          }
        });
  }

  Future<void> _onRefresh() async {
    try {
      final _ = await ref.refresh(projectListProvider.future);

      if (_selectedProjectId != null && _selectedProjectId!.isNotEmpty) {
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

  Future<void> _completeSprintProcess(String carryOverSprintId) async {
    if (_selectedSprintId == null) return;

    try {
      showSuccessSnackBar(context, 'Completing sprint...');

      await ref
          .read(completeSprintRepositoryProvider)
          .completeSprint(
            sprintId: _selectedSprintId!,
            carryOverSprintId: carryOverSprintId,
          );

      if (mounted) {
        showSuccessSnackBar(context, 'Sprint completed successfully!');

        await _onRefresh();
      }
    } catch (e) {
      final errorText = e.toString();
      debugPrint('Error completing sprint: $errorText');
      final message = errorText.contains('do not have permission')
          ? 'Permission denied from server, please try again.'
          : 'Failed to complete sprint. Please try again.';
      if (mounted) {
        showErrorSnackBar(context, message);
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
            roleName == 'admin' ||
            roleName == 'super admin' ||
            roleName.contains('manager');

        return Scaffold(
          drawer: const AppDrawer(),
          backgroundColor: background,
          body: SafeArea(
            child: ref
                .watch(checkConnectivityProvider)
                .when(
                  data: (results) {
                    if (results.contains(ConnectivityResult.none)) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TopBar(
                            title: 'Sprints',
                            onBack: () {
                              if (Navigator.canPop(context))
                                Navigator.pop(context);
                            },
                          ),
                          Expanded(
                            child: GlobalError(
                              message: 'Please check your internet connection.',
                              isNetworkError: true,
                              onRetry: () =>
                                  ref.invalidate(checkConnectivityProvider),
                            ),
                          ),
                        ],
                      );
                    }

                    final projectId = _selectedProjectId ?? widget.projectId;

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TopBar(
                            title: 'Sprints',
                            onBack: () {
                              if (Navigator.canPop(context))
                                Navigator.pop(context);
                            },
                            onInfoTap: () async {
                              if (_isRefreshingData) return;

                              setState(() => _isRefreshingData = true);
                              try {
                                final _ = await ref.refresh(
                                  projectListProvider.future,
                                );
                                if (_selectedProjectId != null &&
                                    _selectedProjectId!.isNotEmpty) {
                                  final _ = await ref.refresh(
                                    sprintListProvider(
                                      _selectedProjectId!,
                                    ).future,
                                  );
                                  final _ = await ref.refresh(
                                    hierarchyProvider((
                                      projectId: _selectedProjectId!,
                                      sprintId: _selectedSprintId,
                                    )).future,
                                  );
                                }
                                if (mounted) {
                                  showSuccessSnackBar(
                                    context,
                                    'Data refreshed successfully',
                                  );
                                }
                              } catch (e) {
                                debugPrint('Refresh error: $e');
                                if (mounted) {
                                  showErrorSnackBar(
                                    context,
                                    'Refresh failed. Please try again.',
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
                          Consumer(
                            builder: (context, ref, _) {
                              final projectsAsync = ref.watch(
                                projectListProvider,
                              );
                              if (projectsAsync.hasValue) {
                                _syncProjectSelection(projectsAsync.value!);
                              }
                              return SprintProjectSelector(
                                projectsAsync: projectsAsync,
                                selectedProjectName: _selectedProjectName,
                                selectedSprintId: _selectedSprintId,
                                selectedSprintStatus: _selectedSprintStatus,
                                selectedSprintName: _selectedSprintName,
                                canManageSprints: canManageSprints,
                                cardBg: cardBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                greyBorder: greyBorder,
                                primary: primary,
                                onProjectTap: () => showProjectSelectorDialog(
                                  context: context,
                                  projects: projectsAsync.value ?? [],
                                  selectedProjectName: _selectedProjectName,
                                  cardBg: cardBg,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  greyBorder: greyBorder,
                                  primary: primary,
                                  onSelect: (project) {
                                    setState(() {
                                      _selectedProjectName =
                                          project.projectName;
                                      _selectedProjectId = project.id;
                                      _selectedSprintName = null;
                                      _selectedSprintId = null;
                                      _selectedSprintStatus = null;
                                    });
                                    _persistSelection();
                                    debugPrint(
                                      'Selected Project: $_selectedProjectName ($_selectedProjectId)',
                                    );
                                  },
                                ),
                                onCompleteSprintTap: () async {
                                  if (_selectedProjectId == null ||
                                      _selectedProjectId!.isEmpty) {
                                    return;
                                  }
                                  final sprints = await ref
                                      .read(getSprintsRepositoryProvider)
                                      .fetchSprints(
                                        projectId: _selectedProjectId!,
                                      );
                                  if (!mounted) return;
                                  await showCarryOverSprintSelectorDialog(
                                    context: this.context,
                                    sprints: sprints,
                                    currentSprintId: _selectedSprintId,
                                    cardBg: cardBg,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    greyBorder: greyBorder,
                                    primary: primary,
                                    onConfirm: _completeSprintProcess,
                                  );
                                },
                              );
                            },
                          ),

                          // ── Cycle status + Sprint dropdown + action buttons ──
                          Consumer(
                            builder: (context, ref, _) {
                              final sprintsAsync =
                                  projectId != null && projectId.isNotEmpty
                                  ? ref.watch(sprintListProvider(projectId))
                                  : const AsyncValue<List<SprintModel>>.data(
                                      [],
                                    );
                              if (sprintsAsync.hasValue) {
                                _syncSprintSelection(sprintsAsync.value!);
                              }
                              return SprintCycleBar(
                                sprintsAsync: sprintsAsync,
                                selectedProjectId: _selectedProjectId,
                                selectedProjectName: _selectedProjectName,
                                selectedSprintId: _selectedSprintId,
                                selectedSprintName: _selectedSprintName,
                                selectedSprintStatus: _selectedSprintStatus,
                                canManageSprints: canManageSprints,
                                cardBg: cardBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                greyBorder: greyBorder,
                                primary: primary,
                                widgetProjectId: widget.projectId,
                                widgetProjectName: widget.projectName,
                                onSprintTap: () => showSprintSelectorDialog(
                                  context: context,
                                  sprints: sprintsAsync.value ?? [],
                                  selectedSprintName: _selectedSprintName,
                                  cardBg: cardBg,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  greyBorder: greyBorder,
                                  primary: primary,
                                  onSelect: (sprint) {
                                    setState(() {
                                      _selectedSprintName = sprint.sprintName;
                                      _selectedSprintId = sprint.rowId;
                                      _selectedSprintStatus = sprint.status;
                                    });
                                    _persistSelection();
                                  },
                                ),
                              );
                            },
                          ),

                          // ── Tab bar ──
                          SprintTabBar(
                            tabController: _tabController,
                            tabbarBg: tabbarBg,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            isDark: isDark,
                          ),

                          // ── Tab content ──
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                // Board tab
                                Builder(
                                  builder: (context) {
                                    if (projectId == null ||
                                        projectId.isEmpty) {
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
                                    return SprintBoardTab(
                                      hierarchyAsync: hierarchyAsync,
                                      sprintsAsync: sprintsAsync,
                                      selectedProjectId: _selectedProjectId,
                                      selectedProjectName: _selectedProjectName,
                                      selectedSprintId: _selectedSprintId,
                                      selectedSprintName: _selectedSprintName,
                                      widgetProjectId: widget.projectId,
                                      widgetProjectName: widget.projectName,
                                      canManageSprints: canManageSprints,
                                      activeUserId: activeUser?.userId,
                                      isDark: isDark,
                                      customColors: customColors,
                                      cardBg: cardBg,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                      greyBorder: greyBorder,
                                      primary: primary,
                                      onMove: _moveStory,
                                      totalPoints: _totalPoints,
                                      completedPoints: _completedPoints,
                                      totalStories: _totalStories,
                                      completedStories: _completedStories,
                                      progress: _progress,
                                      onRetry: () => ref.invalidate(
                                        hierarchyProvider((
                                          projectId: projectId,
                                          sprintId: _selectedSprintId,
                                        )),
                                      ),
                                    );
                                  },
                                ),

                                // Backlog tab
                                SprintBacklogTab(
                                  selectedProjectId: _selectedProjectId,
                                  selectedProjectName: _selectedProjectName,
                                  widgetProjectId: widget.projectId,
                                  widgetProjectName: widget.projectName,
                                  textSecondary: textSecondary,
                                ),

                                // Timeline tab
                                Builder(
                                  builder: (context) {
                                    if (projectId == null ||
                                        projectId.isEmpty) {
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
                                    final sprintsAsync = ref.watch(
                                      sprintListProvider(projectId),
                                    );
                                    return SprintTimelineTab(
                                      rawAsync: rawAsync,
                                      sprintsAsync: sprintsAsync,
                                      selectedProjectId: _selectedProjectId,
                                      selectedSprintId: _selectedSprintId,
                                      selectedSprintName: _selectedSprintName,
                                      widgetProjectId: widget.projectId,
                                      isDark: isDark,
                                      customColors: customColors,
                                      cardBg: cardBg,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                      greyBorder: greyBorder,
                                      primary: primary,
                                      canManageSprints: canManageSprints,
                                      currentUserId: activeUser?.userId,
                                      onRetry: () => ref.invalidate(
                                        rawHierarchyProvider(projectId),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  error: (error, stack) => GlobalError(
                    message:
                        'Something went wrong. Please check your connection.',
                    onRetry: () => ref.invalidate(checkConnectivityProvider),
                  ),
                  loading: () =>
                      const GlobalLoader(message: 'Checking connection...'),
                ),
          ),
        );
      },
    );
  }
}
