import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/features/sprints/model/epic_model.dart';
import 'package:dsv360/features/sprints/model/heirarchy_model.dart';
import 'package:dsv360/features/sprints/model/release_milestone_model.dart';
import 'package:dsv360/features/sprints/model/story_model.dart';
import 'package:dsv360/features/sprints/repositories/heirarchy_repository.dart';
import 'package:dsv360/features/sprints/view/pages/create_epic_page.dart';
import 'package:dsv360/features/sprints/view/pages/create_release_page.dart';
import 'package:dsv360/providers/project_provider.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _projectListProvider = FutureProvider((ref) async {
  return ref.read(projectRepositoryProvider).fetchProjects();
});

final _hierarchyProvider =
    FutureProvider.family<HierarchyModel, String>((ref, projectId) async {
  return ref.read(hierarchyRepositoryProvider).fetchHierarchy(
        projectId: projectId,
      );
});

// ── Screen ────────────────────────────────────────────────────────────────────

class NavigatorScreen extends ConsumerStatefulWidget {
  final bool autoFocusSearch;
  final String? projectId;
  final String? projectName;

  const NavigatorScreen({
    super.key,
    this.autoFocusSearch = false,
    this.projectId,
    this.projectName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends ConsumerState<NavigatorScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  String _searchQuery = '';

  String? _selectedProjectId;
  String? _selectedProjectName;

  // expand state keyed by ROWID
  final Map<String, bool> _milestoneExpanded = {};
  final Map<String, bool> _epicExpanded = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _selectedProjectId = widget.projectId;
    _selectedProjectName = widget.projectName;
    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Project selector dialog (same style as sprints screen) ─────────────────

  Future<void> _showProjectSelector({
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: StatefulBuilder(
            builder: (ctx, setDialogState) {
              final filtered = projects.where((p) {
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
                        onChanged: (v) => setDialogState(() => query = v),
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search project...',
                          hintStyle:
                              TextStyle(color: textSecondary, fontSize: 12),
                          isDense: true,
                          filled: true,
                          fillColor: cardBg,
                          prefixIcon:
                              Icon(Icons.search, color: textSecondary, size: 18),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
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
                      child: filtered.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No projects found',
                                  style: TextStyle(
                                      color: textSecondary, fontSize: 12),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final project = filtered[index];
                                final isSelected =
                                    _selectedProjectId == project.id;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    setState(() {
                                      _selectedProjectId = project.id;
                                      _selectedProjectName =
                                          project.projectName;
                                      _milestoneExpanded.clear();
                                      _epicExpanded.clear();
                                    });
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
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

  // ── Filtering ──────────────────────────────────────────────────────────────

  List<ReleaseMilestoneModel> _filterMilestones(
    List<ReleaseMilestoneModel> milestones,
    List<EpicModel> epics,
    List<StoryModel> stories,
  ) {
    if (_searchQuery.isEmpty) return milestones;
    final q = _searchQuery.toLowerCase();
    return milestones.where((m) {
      if (m.title.toLowerCase().contains(q)) return true;
      final mEpics = epics.where((e) => e.milestoneId == m.id);
      return mEpics.any((e) {
        if (e.title.toLowerCase().contains(q)) return true;
        return stories
            .where((s) => s.epicId == e.id)
            .any((s) => s.title.toLowerCase().contains(q));
      });
    }).toList();
  }

  // ── Builders ───────────────────────────────────────────────────────────────

  Color _epicColor(EpicModel epic) {
    try {
      final hex = epic.color.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF1A56DB);
    }
  }

  Widget _buildStoryTile(StoryModel story, Color epicColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: epicColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                story.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                story.id.length > 4
                    ? 'Story-${story.id.substring(story.id.length - 4)}'
                    : 'Story-${story.id}',
                style: TextStyle(
                  color: epicColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpicTile(
    EpicModel epic,
    List<StoryModel> allStories,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isLightMode,
  ) {
    final epicColor = _epicColor(epic);
    final epicStories = allStories.where((s) => s.epicId == epic.id).toList();
    final isExpanded = _epicExpanded[epic.id] ?? false;

    final epicBackground = isLightMode
        ? Colors.grey.withValues(alpha: 0.08)
        : const Color(0xFF2A2A2A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: epicBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () =>
                setState(() => _epicExpanded[epic.id] = !isExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: epicColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      epic.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  _AddButton(
                    color: textSecondary,
                    label: 'Story',
                    onTap: () {
                      // TODO: Implement create story navigation
                    },
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && epicStories.isNotEmpty)
            Column(
              children: [
                ...epicStories.map((s) => _buildStoryTile(s, epicColor)),
                const SizedBox(height: 8),
              ],
            ),
          if (isExpanded && epicStories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No stories',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTile(
    ReleaseMilestoneModel milestone,
    List<EpicModel> allEpics,
    List<StoryModel> allStories,
    Color cardBackground,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isLightMode,
  ) {
    final milestoneEpics =
        allEpics.where((e) => e.milestoneId == milestone.id).toList();
    final isExpanded = _milestoneExpanded[milestone.id] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(
                () => _milestoneExpanded[milestone.id] = !isExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      milestone.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  _AddButton(
                    color: textSecondary,
                    label: 'Epic',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateEpicPage(
                          projectId: _selectedProjectId!,
                          milestoneId: milestone.id,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && milestoneEpics.isNotEmpty)
            Column(
              children: [
                ...milestoneEpics.map(
                  (e) => _buildEpicTile(
                    e,
                    allStories,
                    border,
                    textPrimary,
                    textSecondary,
                    isLightMode,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          if (isExpanded && milestoneEpics.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No epics',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  // ── Project dropdown row (same look as sprints screen) ─────────────────────

  Widget _buildProjectDropdown({
    required List<dynamic> projects,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color greyBorder,
    required Color primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: 35,
                child: GestureDetector(
                  onTap: () => _showProjectSelector(
                    projects: projects,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    greyBorder: greyBorder,
                    primary: primary,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: greyBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedProjectName ?? 'Select Project',
                            style: TextStyle(
                              color: _selectedProjectName == null
                                  ? textSecondary
                                  : textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down,
                            color: textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final primary = customColors.primary ?? const Color(0xFF1A56DB);
    final textPrimary = customColors.textPrimary ?? Colors.black;
    final textSecondary = customColors.textSecondary ?? Colors.grey;
    final cardBackground = customColors.cardBackground ?? Colors.white;
    final surfaceBackground = customColors.surfaceBackground ?? Colors.white;
    final border = customColors.inputBorder ?? Colors.grey.shade300;
    final greyBorder = customColors.greyBorder ?? Colors.grey.shade300;
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    final projectsAsync = ref.watch(_projectListProvider);

    return Scaffold(
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 8),
            child: Column(
              children: [
                TopBar(
                  title: 'Navigator',
                  onBack: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardPage(),
                        ),
                      );
                    }
                  },
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: CustomSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    hintText: 'Search navigator',
                  ),
                ),

                // Project dropdown
                projectsAsync.when(
                  loading: () => _buildProjectDropdown(
                    projects: const [],
                    cardBg: cardBackground,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    greyBorder: greyBorder,
                    primary: primary,
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Text(
                      'Error loading projects',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ),
                  data: (projects) => _buildProjectDropdown(
                    projects: projects,
                    cardBg: cardBackground,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    greyBorder: greyBorder,
                    primary: primary,
                  ),
                ),

                const SizedBox(height: 4),
              ],
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: _selectedProjectId == null || _selectedProjectId!.isEmpty
                ? _buildSelectProjectPrompt(textSecondary, primary)
                : _buildHierarchy(
                    _selectedProjectId!,
                    surfaceBackground,
                    border,
                    textPrimary,
                    textSecondary,
                    primary,
                    isLightMode,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateReleasePage(projectId: widget.projectId!)));
        },
        backgroundColor: primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSelectProjectPrompt(Color textSecondary, Color primary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_outlined,
              size: 56, color: textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'Select a project to view\nthe navigator',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchy(
    String projectId,
    Color cardBackground,
    Color border,
    Color textPrimary,
    Color textSecondary,
    Color primary,
    bool isLightMode,
  ) {
    final hierarchyAsync = ref.watch(_hierarchyProvider(projectId));

    return hierarchyAsync.when(
      data: (hierarchy) {
        final milestones = _filterMilestones(
          hierarchy.milestones,
          hierarchy.epics,
          hierarchy.stories,
        );

        if (milestones.isEmpty) {
          return Center(
            child: Text(
              _searchQuery.isEmpty ? 'No data found' : 'No results found',
              style: TextStyle(color: textSecondary, fontSize: 15),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(_hierarchyProvider(projectId)),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: milestones.length,
            itemBuilder: (context, index) => _buildMilestoneTile(
              milestones[index],
              hierarchy.epics,
              hierarchy.stories,
              cardBackground,
              border,
              textPrimary,
              textSecondary,
              isLightMode,
            ),
          ),
        );
      },
      loading: () => const Center(child: DsvLoader()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                'Failed to load hierarchy',
                style: TextStyle(color: textPrimary, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.invalidate(_hierarchyProvider(projectId)),
                child: Text('Retry',
                    style: TextStyle(color: Colors.blue.shade400)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small reusable add button ─────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const _AddButton({
    required this.color,
    this.label = 'Epic',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 4),
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text("$label "),
            Icon(Icons.add, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
