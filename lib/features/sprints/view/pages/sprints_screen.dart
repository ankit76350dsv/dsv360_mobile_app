import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/dashboard/view/pages/AppDrawer.dart';
import 'package:dsv360/features/sprints/view/pages/create_sprint_page.dart';
import 'package:dsv360/providers/project_provider.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sprint_story.dart';
import '../widgets/board_view.dart';

// ── Sample data ──────────────────────────────────────────────────────────

final _sampleStories = [
  SprintStory(
    id: 's1',
    title: 'Admin Page Design',
    completedPoints: 75,
    totalPoints: 100,
    memberAvatars: ['M'],
    storyLabel: 'Story-3',
    storyPoints: 3,
    columnId: 'not_started',
  ),
  SprintStory(
    id: 's2',
    title: 'Research Price Distribution',
    completedPoints: 0,
    totalPoints: 6,
    memberAvatars: ['M'],
    storyLabel: 'Story-3',
    storyPoints: 3,
    columnId: 'not_started',
  ),
  SprintStory(
    id: 's3',
    title: 'Design Module Patterns',
    completedPoints: 0,
    totalPoints: 8,
    memberAvatars: ['M'],
    storyLabel: 'Story-3',
    storyPoints: 3,
    columnId: 'not_started',
  ),
];

final projectListProvider = FutureProvider((ref) async {
  final repo = ref.read(projectRepositoryProvider);
  return repo.fetchProjects();
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
  late List<SprintStory> _stories;

  String? _selectedProjectName;
  String? _selectedProjectId;
  final String _selectedSprint = 'Sprint-0T';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _stories = List.from(_sampleStories);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _totalPoints => _stories.fold(0, (sum, s) => sum + s.storyPoints);

  int get _completedPoints => _stories
      .where((s) => s.columnId == 'closed' || s.columnId == 'uat_approved')
      .fold(0, (sum, s) => sum + s.storyPoints);

  int get _totalStories => _stories.length;

  int get _completedStories => _stories
      .where((s) => s.columnId == 'closed' || s.columnId == 'uat_approved')
      .length;

  double get _progress =>
      _totalPoints == 0 ? 0.0 : _completedPoints / _totalPoints;

  void _moveStory(SprintStory story, String newColumnId) {
    setState(() {
      story.columnId = newColumnId;
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

        return Scaffold(
          drawer: const AppDrawer(),
          backgroundColor: background,
          body: SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──
                TopBar(
                  title: 'Sprints',
                  onBack: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
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
                                        borderRadius: BorderRadius.circular(8),
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
                                                    _selectedProjectName == null
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
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primary, width: 1.5),
                          ),
                          child: Text(
                            'Complete',
                            style: TextStyle(
                              color: primary,
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
                  child: Row(
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
                      // Active badge
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
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Sprint dropdown
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: greyBorder, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedSprint,
                                style: TextStyle(
                                  color: textPrimary,
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
                      ),
                      const Spacer(),
                      // + SPRINT button
                      GestureDetector(
                        onTap: () {
                          if (_selectedProjectId == null ||
                              _selectedProjectId!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a project first'),
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
                            border: Border.all(color: greyBorder, width: 1),
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
                      // + ISSUE button
                      GestureDetector(
                        onTap: () {
                          //navigate to add issue page here
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: greyBorder, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: primary, size: 13),
                              const SizedBox(width: 2),
                              Text(
                                'ISSUE',
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
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
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
                      BoardView(
                        stories: _stories,
                        onMove: _moveStory,
                        isDark: isDark,
                        customColors: customColors,
                        cardBg: cardBg,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        greyBorder: greyBorder,
                        primary: primary,
                        progress: _progress,
                        completedPoints: _completedPoints,
                        totalPoints: _totalPoints,
                        completedStories: _completedStories,
                        totalStories: _totalStories,
                      ),
                      // Backlog tab
                      Center(
                        child: Text(
                          'Backlog coming soon',
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                      ),
                      // Timeline tab
                      Center(
                        child: Text(
                          'Timeline coming soon',
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
