import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/sprints/model/sprints_model.dart';
import 'package:dsv360/features/sprints/model/story_model.dart';
import 'package:dsv360/features/sprints/repositories/get_sprints_repository.dart';
import 'package:dsv360/features/sprints/repositories/heirarchy_repository.dart';
import 'package:dsv360/features/sprints/repositories/deploy_to_cycle_repository.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Providers ──────────────────────────────────────────────────────────────────

final _backlogHierarchyProvider =
    FutureProvider.family<List<StoryModel>, String>((ref, projectId) async {
  final hierarchy = await ref
      .read(hierarchyRepositoryProvider)
      .fetchHierarchy(projectId: projectId);
  return hierarchy.stories
      .where((s) => s.sprintId.isEmpty || s.sprintId == '0')
      .toList();
});

final _backlogSprintsProvider =
    FutureProvider.family<List<SprintModel>, String>((ref, projectId) async {
  return ref
      .read(getSprintsRepositoryProvider)
      .fetchSprints(projectId: projectId);
});

// ── Page ───────────────────────────────────────────────────────────────────────

class BacklogPage extends ConsumerStatefulWidget {
  final String projectId;
  final String? projectName;

  const BacklogPage({
    super.key,
    required this.projectId,
    this.projectName,
  });

  @override
  ConsumerState<BacklogPage> createState() => _BacklogPageState();
}

class _BacklogPageState extends ConsumerState<BacklogPage> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<StoryModel> _filtered(List<StoryModel> stories) {
    if (_searchQuery.isEmpty) return stories;
    final q = _searchQuery.toLowerCase();
    return stories
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.moduleName.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _showSprintSelector({
    required BuildContext context,
    required StoryModel story,
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
        final maxHeight = MediaQuery.of(dialogContext).size.height * 0.55;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: StatefulBuilder(
            builder: (ctx, setDialogState) {
              final filtered = sprints.where((s) {
                return s.sprintName
                    .toLowerCase()
                    .contains(query.toLowerCase());
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
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: Text(
                        'Deploy to Cycle',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: TextField(
                        autofocus: true,
                        onChanged: (v) => setDialogState(() => query = v),
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search sprint...',
                          hintStyle: TextStyle(
                              color: textSecondary, fontSize: 12),
                          isDense: true,
                          filled: true,
                          fillColor: cardBg,
                          prefixIcon: Icon(Icons.search,
                              color: textSecondary, size: 18),
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
                                  'No sprints found',
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
                                final sprint = filtered[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    Navigator.pop(dialogContext);
                                    _deployCycle(story, sprint);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            sprint.sprintName,
                                            style: TextStyle(
                                              color: textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primary
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            sprint.status,
                                            style: TextStyle(
                                              color: primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
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

  void _deployCycle(StoryModel story, SprintModel sprint) {
    ref
        .read(deployToCycleRepositoryProvider)
        .deployToSprint(storyId: story.id, sprintId: sprint.rowId)
        .then((_) {
      ref.invalidate(_backlogHierarchyProvider(widget.projectId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '"${story.title}" deployed to ${sprint.sprintName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to deploy: $e')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, mode, _) {
        final customColors = Theme.of(context).custom;
        final isDark = mode == ThemeMode.dark;

        final background = customColors.background ??
            (isDark
                ? AppColorsDark.background
                : AppColorsLight.background);
        final cardBg = customColors.cardBackground ??
            (isDark
                ? AppColorsDark.cardBackground
                : AppColorsLight.cardBackground);
        final textPrimary = customColors.textPrimary ??
            (isDark
                ? AppColorsDark.textPrimary
                : AppColorsLight.textPrimary);
        final textSecondary = customColors.textSecondary ??
            (isDark
                ? AppColorsDark.textSecondary
                : AppColorsLight.textSecondary);
        final greyBorder = customColors.greyBorder ??
            (isDark
                ? AppColorsDark.greyBorder
                : AppColorsLight.greyBorder);
        final primary =
            customColors.primary ?? AppColorsDark.primary;

        final activeUser = ref.watch(activeUserRepositoryProvider);
        final roleName = (activeUser?.roleName ?? '').toLowerCase().trim();
        final canManageSprints = roleName == 'admin' || roleName == 'super admin';

        final hierarchyAsync =
            ref.watch(_backlogHierarchyProvider(widget.projectId));
        final sprintsAsync =
            ref.watch(_backlogSprintsProvider(widget.projectId));

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              

               

                // // ── Search bar ──
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 16, vertical: 8),
                //   child: CustomSearchBar(
                //     controller: _searchController,
                //     focusNode: _searchFocusNode,
                //     onChanged: (value) =>
                //         setState(() => _searchQuery = value),
                //     hintText: 'Search backlog',
                //   ),
                // ),

                 // ── Description + Pool Size ──
                hierarchyAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (stories) {
                    final roleFiltered = canManageSprints
                        ? stories
                        : stories
                            .where((s) => s.assigneeId == activeUser?.userId)
                            .toList();
                    final count = _filtered(roleFiltered).length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Strategic scope pool awaiting cycle operationalization.',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Text(
                                'Pool Size',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: greyBorder, width: 1),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 10,),

                // ── Story list ──
                Expanded(
                  child: hierarchyAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48,
                                color: Colors.red.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load backlog',
                              style: TextStyle(
                                  color: textPrimary, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              e.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => ref.invalidate(
                                  _backlogHierarchyProvider(
                                      widget.projectId)),
                              child: Text('Retry',
                                  style: TextStyle(
                                      color: Colors.blue.shade400)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (stories) {
                      final roleFiltered = canManageSprints
                          ? stories
                          : stories
                              .where((s) => s.assigneeId == activeUser?.userId)
                              .toList();
                      final filtered = _filtered(roleFiltered);
                      if (filtered.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async => ref.invalidate(
                              _backlogHierarchyProvider(widget.projectId)),
                          child: ListView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                        0.5,
                                child: Center(
                                  child: Text(
                                    _searchQuery.isEmpty
                                        ? 'No backlog stories'
                                        : 'No results found',
                                    style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(_backlogHierarchyProvider(
                              widget.projectId));
                          ref.invalidate(_backlogSprintsProvider(
                              widget.projectId));
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 24),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final story = filtered[index];
                            final storyNumber = index + 1;

                            return _BacklogStoryCard(
                              story: story,
                              storyNumber: storyNumber,
                              sprintsAsync: sprintsAsync,
                              cardBg: cardBg,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              greyBorder: greyBorder,
                              primary: primary,
                              isDark: isDark,
                              onDeployTap: (sprints) =>
                                  _showSprintSelector(
                                context: context,
                                story: story,
                                sprints: sprints,
                                cardBg: cardBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                greyBorder: greyBorder,
                                primary: primary,
                              ),
                            );
                          },
                        ),
                      );
                    },
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

// ── Story Card ─────────────────────────────────────────────────────────────────

class _BacklogStoryCard extends StatelessWidget {
  final StoryModel story;
  final int storyNumber;
  final AsyncValue<List<SprintModel>> sprintsAsync;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color greyBorder;
  final Color primary;
  final bool isDark;
  final void Function(List<SprintModel>) onDeployTap;

  const _BacklogStoryCard({
    required this.story,
    required this.storyNumber,
    required this.sprintsAsync,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.greyBorder,
    required this.primary,
    required this.isDark,
    required this.onDeployTap,
  });

  Color get _statusColor {
    switch (story.status.toLowerCase()) {
      case 'wip':
        return const Color(0xFF2196F3);
      case 'closed':
        return const Color(0xFF4CAF50);
      case 'not_started':
      case 'not started':
        return const Color(0xFF9E9E9E);
      case 'released_for_uat':
      case 'released for uat':
        return const Color(0xFF9C27B0);
      case 'uat_approved':
      case 'uat approved':
        return const Color(0xFF4CAF50);
      case 'backlog':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFFFF9800);
    }
  }

  String get _displayStatus {
    if (story.status.isEmpty) return 'BACKLOG';
    return story.status.toUpperCase().replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greyBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Title + Story label ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    story.title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'STORY-$storyNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Row 2: Module name + SP ──
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: greyBorder, width: 1),
                    ),
                    child: Text(
                      story.moduleName.isNotEmpty
                          ? story.moduleName
                          : 'No Module',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: greyBorder, width: 1),
                  ),
                  child: Text(
                    '${story.points} SP',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Row 3: Status ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: greyBorder, width: 1),
                  ),
                  child: Text(
                    _displayStatus,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Row 4: Deploy to Cycle Button ──
            Row(
              children: [
                Expanded(
                  child: sprintsAsync.when(
                    loading: () => _DeployButton(
                      primary: primary,
                      label: 'Loading...',
                      onTap: null,
                    ),
                    error: (_, __) => _DeployButton(
                      primary: primary,
                      label: 'DEPLOY TO CYCLE',
                      onTap: null,
                    ),
                    data: (sprints) => _DeployButton(
                      primary: primary,
                      label: 'DEPLOY TO CYCLE',
                      onTap: () => onDeployTap(sprints),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Deploy Button ──────────────────────────────────────────────────────────────

class _DeployButton extends StatelessWidget {
  final Color primary;
  final String label;
  final VoidCallback? onTap;

  const _DeployButton({
    required this.primary,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
