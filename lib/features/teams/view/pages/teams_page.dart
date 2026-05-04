import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/teams/view/pages/add_edit_team.dart';
import 'package:dsv360/features/teams/providers/teams_provider.dart';
import 'package:dsv360/features/teams/viewmodel/teams_viewmodel.dart';
import 'package:dsv360/features/teams/view/widgets/responsive_scale_helper.dart';
import 'package:dsv360/features/teams/view/widgets/team_board.dart';
import 'package:dsv360/features/teams/view/widgets/employee_card.dart';
import 'package:dsv360/features/teams/view/widgets/empty_drop_zone.dart';
import 'package:dsv360/features/teams/view/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/features/dashboard/view/pages/AppDrawer.dart';
import 'package:dsv360/features/teams/providers/batch_profile_provider.dart';

// ── Alias for responsive scale class ──
typedef _RS = ResponsiveScale;

// ╔══════════════════════════════════════════════════════════════╗
// ║                    TEAMS PAGE (MAIN)                        ║
// ╚══════════════════════════════════════════════════════════════╝

class TeamsPage extends ConsumerStatefulWidget {
  const TeamsPage({super.key});

  @override
  ConsumerState<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends ConsumerState<TeamsPage> {
  String _unassignedSearch = '';
  bool _isUnassignedDragOver = false;
  late List<Team> _teams;
  late List<Employee> _employees;
  bool _isLoadingTeams = true;
  bool _isLoadingEmployees = true;
  String? _deletingTeamId;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _teams = [];
    _employees = [];
    _loadTeams();
    _loadEmployees();
  }

  Future<void> _loadTeams() async {
    try {
      final teamModels = await ref.read(teamsProvider.future);
      // Convert API Team models to local Team class with manager info
      setState(() {
        _teams = teamModels
            .map((t) => Team(
              id: t.rowId,
              name: t.teamName,
              reportingManagerId: t.teamReportingManagerId,
              reportingManager: t.teamReportingManager,
            ))
            .toList();
        _isLoadingTeams = false;
      });
    } catch (e) {
      debugPrint('Error loading teams: $e');
      setState(() {
        _isLoadingTeams = false;
      });
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final batchProfiles = await ref.read(batchProfilesProvider.future);
      // Convert batch profile response to local Employee class used in teams page
      setState(() {
        _employees = batchProfiles
            .map((profile) => Employee(
              id: profile.userId,
              name: profile.fullName,
              phone: profile.phone ?? '',
              profileImageUrl:
                  profile.profilePic.isNotEmpty ? profile.profilePic : null,
              teamId: profile.teamId,
            ))
            .toList();
        _isLoadingEmployees = false;
      });
    } catch (e) {
      debugPrint('Error loading batch profiles: $e');
      setState(() {
        _isLoadingEmployees = false;
      });
      if (mounted) {
        final connectivity = await Connectivity().checkConnectivity();
        if (!mounted) return;
        if (!connectivity.contains(ConnectivityResult.none)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to load employees. Please try again.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    ref.invalidate(teamsProvider);
    ref.invalidate(batchProfilesProvider);
    await Future.wait([_loadTeams(), _loadEmployees()]);
    if (mounted) setState(() => _isRefreshing = false);
  }

  // ── Helpers ──
  List<Employee> _employeesInTeam(String teamId) =>
      _employees.where((e) => e.teamId == teamId).toList();

  List<Employee> get _unassigned {
    final all = _employees.where((e) => e.teamId == null).toList();
    if (_unassignedSearch.trim().isEmpty) return all;
    final q = _unassignedSearch.toLowerCase();
    return all
        .where((e) =>
            e.name.toLowerCase().contains(q) || e.phone.contains(q))
        .toList();
  }

  int get _totalUnassigned =>
      _employees.where((e) => e.teamId == null).length;

  Future<void> _moveEmployee(
    Employee employee,
    String? targetTeamId,
    String? targetTeamName,
  ) async {
    if (employee.teamId == targetTeamId) return;

    try {
      final teamNotifier = ref.read(teamNotifierProvider.notifier);
      await teamNotifier.assignUserToTeam(
        userId: employee.id,
        teamId: targetTeamId,
        teamName: targetTeamName,
      );

      await _loadTeams();
      await _loadEmployees();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save team assignment. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ── Dialogs ──
  Future<void> _showAddTeamDialog() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTeamPage()),
    );

    if (!mounted || result == null) return;

    final teamName = (result['teamName'] ?? '').toString().trim();
    if (teamName.isEmpty) return;

    // Refresh teams list from API after successful creation
    _loadTeams();
  }

  Future<void> _showEditTeamDialog(Team team) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTeamPage(
          teamId: team.id,
          teamName: team.name,
          reportingManager: team.reportingManager,
          reportingManagerId: team.reportingManagerId,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final updatedName = (result['teamName'] ?? '').toString().trim();
    if (updatedName.isEmpty) return;

    // Refresh teams list from API after successful update
    _loadTeams();
  }

  void _confirmDeleteTeam(Team team) {
    // Check if team has members
    final teamMembers = _employeesInTeam(team.id);
    if (teamMembers.isNotEmpty) {
      // Show error if team has members
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot delete team with members. Please unassign all members first.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    showWarningDialogueBox<bool>(
      context: context,
      title: 'Delete Team',
      subtitle: 'Are you sure you want to delete "${team.name}"?',
      primaryText: 'Delete',
      onPrimaryPressed: (dialogContext) async {
        Navigator.of(dialogContext).pop(true);
        
        // Set loading state for this team
        setState(() => _deletingTeamId = team.id);

        try {
          // Call delete API
          final teamNotifier = ref.read(teamNotifierProvider.notifier);
          await teamNotifier.deleteTeam(team.id);

          // Remove from local state
          setState(() {
            for (final e in _employees) {
              if (e.teamId == team.id) e.teamId = null;
            }
            _teams.removeWhere((t) => t.id == team.id);
            _deletingTeamId = null;
          });

          // Show success snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Team "${team.name}" deleted successfully'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          // Refresh teams list from API
          _loadTeams();
        } catch (e) {
          setState(() => _deletingTeamId = null);

          // Show error snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to delete team. Please try again.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      },
    );
  }

  // ╔══════════════════════════════════════════════════════════╗
  // ║                        BUILD                            ║
  // ╚══════════════════════════════════════════════════════════╝
  @override
  Widget build(BuildContext context) {
    // One RS instance for the whole page — derived from screen width
    final rs = _RS(MediaQuery.of(context).size.width);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, mode, _) {
        final customColors = Theme.of(context).custom;
        final isDark = mode == ThemeMode.dark;
        final background = customColors.background ??
            (isDark ? AppColorsDark.background : AppColorsLight.background);
        final cardBackground = customColors.cardBackground ??
            (isDark ? AppColorsDark.cardBackground : AppColorsLight.cardBackground);
        final textHint = customColors.textHint ??
            (isDark ? AppColorsDark.textHint : AppColorsLight.textHint);
        final textSecondary = customColors.textSecondary ??
            (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary);
        final textPrimary = customColors.textPrimary ??
            (isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary);

        final connectivityStatus = ref.watch(checkConnectivityProvider);

        return Scaffold(
          drawer: const AppDrawer(),
          backgroundColor: background,
          body: SafeArea(
            child: connectivityStatus.when(
              data: (results) {
                if (results.contains(ConnectivityResult.none)) {
                  return Column(
                    children: [
                      TopBar(
                        title: 'Teams',
                        onBack: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: GlobalError(
                          message: 'Please check your internet connection.',
                          isNetworkError: true,
                          onRetry: () => ref.invalidate(checkConnectivityProvider),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
              children: [
                // ── Top bar ──
                TopBar(
                  title: 'Teams',
                  onBack: () => Navigator.pop(context),
                  onInfoTap: _refresh,
                  actionIcon: Icons.refresh_rounded,
                ),

                // ── Body (55 / 45 split) ──
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalH = constraints.maxHeight;
                      final upperH = totalH * 0.55;
                      final lowerH = totalH * 0.45;

                      // Grid cell aspect ratio: shrinks on small screens so
                      // avatar + name + phone all fit without overflow.
                      // 2.6 on 390 px; approaches 1.9 at the minimum scale.
                      final gridAspect = (rs.scale * 3.0).clamp(2.2, 3.0);

                      return Column(
                        children: [
                          // ════════════════════════════════════════
                          //   UPPER 55% — horizontal board scroll
                          // ════════════════════════════════════════
                          SizedBox(
                            height: upperH,
                            child: _isLoadingTeams
                                ? Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  )
                                : _teams.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.group_outlined,
                                                size: rs.s(40),
                                                color: textHint),
                                            SizedBox(height: rs.s(8)),
                                            Text(
                                              'No teams yet. Add one below.',
                                              style: TextStyle(
                                                color: textSecondary,
                                                fontSize: rs.f(14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: rs.insets(
                                            const EdgeInsets.fromLTRB(
                                                16, 14, 4, 10)),
                                        itemCount: _teams.length,
                                        itemBuilder: (_, i) {
                                          final team = _teams[i];
                                          return TeamBoard(
                                            team: team,
                                            employees:
                                                _employeesInTeam(team.id),
                                            onEmployeeDropped: (emp, tid, tname) =>
                                                _moveEmployee(emp, tid, tname),
                                            onEdit: () =>
                                                _showEditTeamDialog(team),
                                            onDelete: () =>
                                                _confirmDeleteTeam(team),
                                            rs: rs,
                                            isDeleting: _deletingTeamId == team.id,
                                          );
                                        },
                                      ),
                          ),

                          // ════════════════════════════════════════
                          //   LOWER 45% — unassigned 2-col grid
                          // ════════════════════════════════════════
                          Container(
                            height: lowerH,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  width: 0.8,
                                  color: customColors.greyBorder ??
                                      (isDark
                                          ? AppColorsDark.greyBorder
                                          : AppColorsLight.greyBorder),
                                ),
                              ),
                              color: cardBackground,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                      alpha: isDark ? 0.35 : 0.09),
                                  blurRadius: 16,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: rs.s(16)),

                                // ── Header row ──
                                Padding(
                                  padding: rs.insets(
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Orange icon box
                                      Container(
                                        width: rs.s(38),
                                        height: rs.s(38),
                                        decoration: BoxDecoration(
                                          color: (customColors.statusInProgress ??
                                                  customColors.primary ??
                                                  const Color(0xFFE07820))
                                              .withValues(alpha: 0.16),
                                          borderRadius: rs.radius(11),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: customColors
                                                  .statusInProgress ??
                                              customColors.primary ??
                                              const Color(0xFFE07820),
                                          size: rs.s(21),
                                        ),
                                      ),
                                      SizedBox(width: rs.s(10)),
                                      // Title + member count
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Unassigned',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: rs.f(15),
                                              color: textPrimary,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          Text(
                                            '$_totalUnassigned Members',
                                            style: TextStyle(
                                              fontSize: rs.f(11),
                                              color: textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      // +Add Team button
                                      GestureDetector(
                                        onTap: _showAddTeamDialog,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: rs.s(12),
                                            vertical: rs.s(8),
                                          ),
                                          decoration: BoxDecoration(
                                            color: customColors.primary,
                                            borderRadius: rs.radius(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (customColors.primary ??
                                                        const Color(0xFF2563EB))
                                                    .withValues(alpha: 0.3),
                                                blurRadius: rs.s(8),
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '+ Add Team',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: rs.f(12),
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: rs.s(8)),

                                // ── Search bar ──
                                Padding(
                                  padding: rs.sym(h: 16),
                                  child: SearchField(
                                    hintText: 'Search Unassigned...',
                                    onChanged: (v) => setState(
                                        () => _unassignedSearch = v),
                                    rs: rs,
                                  ),
                                ),
                                SizedBox(height: rs.s(6)),

                                // ── Unassigned drag-target 2-col grid ──
                                Expanded(
                                  child: _isLoadingEmployees
                                      ? Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        )
                                      : DragTarget<Employee>(
                                          onWillAccept: (data) {
                                            if (data == null ||
                                                data.teamId == null)
                                              return false;
                                            HapticFeedback.selectionClick();
                                            setState(() =>
                                                _isUnassignedDragOver = true);
                                            return true;
                                          },
                                          onLeave: (_) => setState(() =>
                                              _isUnassignedDragOver = false),
                                          onAccept: (emp) {
                                            HapticFeedback.mediumImpact();
                                            setState(() =>
                                                _isUnassignedDragOver = false);
                                            _moveEmployee(emp, null, null);
                                          },
                                          builder: (ctx, candidate, rejected) {
                                            return AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 180),
                                              curve: Curves.easeOut,
                                              margin: rs.sym(h: 16),
                                              decoration: _isUnassignedDragOver
                                                  ? BoxDecoration(
                                                      color: (customColors
                                                              .statusInProgress ??
                                                          customColors
                                                              .primary ??
                                                          const Color(
                                                              0xFFE07820))
                                                          .withValues(
                                                              alpha: 0.12),
                                                      borderRadius:
                                                          rs.radius(14),
                                                      border: Border.all(
                                                          color: customColors
                                                                  .statusInProgress ??
                                                              customColors
                                                                  .primary ??
                                                              const Color(
                                                                  0xFFE07820),
                                                          width: 2),
                                                    )
                                                  : null,
                                              child: _unassigned.isEmpty
                                                  ? EmptyDropZone(rs: rs)
                                                  : GridView.builder(
                                                      padding:
                                                          EdgeInsets.only(
                                                        top: rs.s(4),
                                                        bottom: rs.s(12),
                                                      ),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        crossAxisSpacing:
                                                            rs.s(8),
                                                        mainAxisSpacing:
                                                            rs.s(3),
                                                        childAspectRatio:
                                                            gridAspect,
                                                      ),
                                                      itemCount:
                                                          _unassigned.length,
                                                      itemBuilder: (_, i) =>
                                                          EmployeeCard(
                                                        employee:
                                                            _unassigned[i],
                                                        rs: rs,
                                                        isGrid: true,
                                                      ),
                                                    ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
                );
              },
              error: (error, stack) => GlobalError(
                message: 'Something went wrong. Please check your connection.',
                onRetry: () => ref.invalidate(checkConnectivityProvider),
              ),
              loading: () => const GlobalLoader(message: 'Checking connection...'),
            ),
          ),
        );
      },
    );
  }
}
