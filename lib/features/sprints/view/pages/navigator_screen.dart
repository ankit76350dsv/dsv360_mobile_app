import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Sample data models ──────────────────────────────────────────────────────

class _StoryItem {
  final String id;
  final String name;

  const _StoryItem({required this.id, required this.name});
}

class _EpicItem {
  final String id;
  final String name;
  final List<_StoryItem> stories;
  bool expanded;

  _EpicItem({
    required this.id,
    required this.name,
    required this.stories,
    this.expanded = false,
  });
}

class _ReleaseItem {
  final String id;
  final String name;
  final List<_EpicItem> epics;
  bool expanded;

  _ReleaseItem({
    required this.id,
    required this.name,
    required this.epics,
    this.expanded = false,
  });
}

final List<_ReleaseItem> _sampleReleases = [
  _ReleaseItem(
    id: 'r1',
    name: 'v1.0 - MVP Release',
    epics: [
      _EpicItem(
        id: 'e1',
        name: 'Authentication and Flow',
        stories: [
          _StoryItem(id: 'Story-1', name: 'User Login & Research'),
          _StoryItem(id: 'Story-2', name: 'Password Recovery Flow'),
        ],
      ),
    ],
  ),
  _ReleaseItem(
    id: 'r2',
    name: 'Time Tracking Module Release',
    epics: [
      _EpicItem(
        id: 'e2',
        name: 'Timer Core',
        stories: [
          _StoryItem(id: 'Story-3', name: 'Start & Stop Timer'),
        ],
      ),
    ],
  ),
  _ReleaseItem(
    id: 'r3',
    name: 'v2.0 - Advanced Function Release',
    epics: [],
  ),
  _ReleaseItem(
    id: 'r4',
    name: 'V3.0 - MVP Release',
    expanded: true,
    epics: [
      _EpicItem(
        id: 'e3',
        name: 'Authentication and Flow',
        stories: [],
      ),
      _EpicItem(
        id: 'e4',
        name: 'Time Tracking Module',
        expanded: true,
        stories: [
          _StoryItem(id: 'Story-4', name: 'User Login & Research'),
          _StoryItem(id: 'Story-5', name: 'Role Based Account Redirect'),
        ],
      ),
    ],
  ),
  _ReleaseItem(
    id: 'r5',
    name: 'V4.0 - MVP Release',
    expanded: true,
    epics: [
      _EpicItem(
        id: 'e5',
        name: 'Create Project Flow',
        expanded: true,
        stories: [
          _StoryItem(id: 'Story-6', name: 'Design Flow Architecture'),
        ],
      ),
    ],
  ),
];

// ── Screen ──────────────────────────────────────────────────────────────────

class NavigatorScreen extends ConsumerStatefulWidget {
  const NavigatorScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends ConsumerState<NavigatorScreen> {
  late TextEditingController _searchController;
  late List<_ReleaseItem> _releases;
  String _searchQuery = '';
  final storyColor = const Color.fromARGB(255, 116, 29, 255);
  

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _releases = _sampleReleases
        .map(
          (r) => _ReleaseItem(
            id: r.id,
            name: r.name,
            expanded: r.expanded,
            epics: r.epics
                .map(
                  (e) => _EpicItem(
                    id: e.id,
                    name: e.name,
                    expanded: e.expanded,
                    stories: e.stories,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ReleaseItem> get _filtered {
    if (_searchQuery.isEmpty) return _releases;
    final q = _searchQuery.toLowerCase();
    return _releases
        .where(
          (r) =>
              r.name.toLowerCase().contains(q) ||
              r.epics.any(
                (e) =>
                    e.name.toLowerCase().contains(q) ||
                    e.stories.any((s) => s.name.toLowerCase().contains(q)),
              ),
        )
        .toList();
  }

  // ── Builders ───────────────────────────────────────────────────────────────

  Widget _buildStoryTile(_StoryItem story, Color primary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: primary,
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
                story.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                story.id,
                style: TextStyle(
                  color: primary,
                  fontSize: 12,
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
    _EpicItem epic,
    Color primary,
    Color surface,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isLightMode,
  ) {
    // Use grey with 0.7 opacity in light mode, otherwise use surface color
    final epicBackground = isLightMode 
        ? Colors.grey.withValues(alpha: 0.1)
        : surface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: epicBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => epic.expanded = !epic.expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      epic.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  _AddButton(color: textSecondary),
                  const SizedBox(width: 6),
                  Icon(
                    epic.expanded ? Icons.expand_less : Icons.expand_more,
                    color: textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (epic.expanded && epic.stories.isNotEmpty)
            Column(
              children: [
                ...epic.stories.map((s) => _buildStoryTile(s, storyColor)),
                const SizedBox(height: 8),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReleaseTile(
    _ReleaseItem release,
    Color primary,
    Color cardBackground,
    Color surface,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isLightMode,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => release.expanded = !release.expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      release.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  _AddButton(color: textSecondary),
                  const SizedBox(width: 6),
                  Icon(
                    release.expanded ? Icons.expand_less : Icons.expand_more,
                    color: textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (release.expanded && release.epics.isNotEmpty)
            Column(
              children: [
                ...release.epics.map(
                  (e) => _buildEpicTile(
                    e,
                    primary,
                    surface,
                    border,
                    textPrimary,
                    textSecondary,
                    isLightMode,
                  ),
                ),
                const SizedBox(height: 8),
              ],
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
    final textSecondary =
        customColors.textSecondary ?? Colors.grey;
    final cardBackground =
        customColors.surfaceBackground ?? Colors.white;
    final surface = customColors.cardBackground ?? const Color(0xFFF5F5F5);
    final border = customColors.inputBorder ?? Colors.grey.shade300;
    
    // Detect if light mode
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    final filtered = _filtered;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 12),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: CustomSearchBar(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    hintText: 'Search navigator',
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(color: textSecondary, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _buildReleaseTile(
                      filtered[index],
                      primary,
                      cardBackground,
                      surface,
                      border,
                      textPrimary,
                      textSecondary,
                      isLightMode,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Small reusable add button ────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final Color color;

  const _AddButton({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Icons.add, color: color, size: 18),
    );
  }
}