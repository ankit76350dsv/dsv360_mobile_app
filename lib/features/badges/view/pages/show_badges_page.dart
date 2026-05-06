import 'package:dsv360/core/widgets/TopBar.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/badges/model/badge_summary.dart';
import 'package:dsv360/features/badges/model/dsvbadge.dart';
import 'package:dsv360/features/badges/view/pages/add_edit_badge_page.dart';
import 'package:dsv360/features/badges/view/widgets/show_badge_list_tile.dart';
import 'package:dsv360/features/badges/viewmodel/badges_viewmodel.dart';
import 'package:dsv360/core/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowBadgesPage extends ConsumerStatefulWidget {
  const ShowBadgesPage({super.key});

  @override
  ConsumerState<ShowBadgesPage> createState() => _ShowBadgesPageState();
}

class _ShowBadgesPageState extends ConsumerState<ShowBadgesPage> {
  late Future<List<BadgeSummary>> _badgesFuture;
  late final TextEditingController _searchController;
  String? _deletingBadgeKey;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    ref.read(showBadgesSearchQueryProvider.notifier).state = '';
    _badgesFuture = _fetchBadges();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<BadgeSummary>> _fetchBadges() {
    return ref.read(showBadgesViewModelProvider).fetchBadges();
  }

  Future<void> _deleteBadge(BadgeSummary badge) async {
    if (_deletingBadgeKey != null) return;

    setState(() {
      _deletingBadgeKey = badge.rowId.isNotEmpty ? badge.rowId : badge.badgeId;
    });

    try {
      await ref.read(showBadgesViewModelProvider).deleteBadge(badge);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Badge deleted successfully')),
      );

      _retryFetch();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete badge')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _deletingBadgeKey = null;
      });
    }
  }

  void _retryFetch() {
    setState(() {
      _badgesFuture = _fetchBadges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).colorScheme;
    final query = ref.watch(showBadgesSearchQueryProvider).toLowerCase();

    return Scaffold(
      
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              title: 'All Badges',
              onBack: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: CustomSearchBar(
                controller: _searchController,
                hintText: 'Search badges',
                onChanged: (value) {
                  ref.read(showBadgesSearchQueryProvider.notifier).state = value;
                },
                onClear: () {
                  ref.read(showBadgesSearchQueryProvider.notifier).state = '';
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<BadgeSummary>>(
                future: _badgesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: DsvLoader());
                  }
        
                  if (snapshot.hasError && !snapshot.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              snapshot.error.toString().replaceFirst('Exception: ', ''),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _retryFetch,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
        
                  final badges = snapshot.data ?? const <BadgeSummary>[];
                  final filteredBadges = badges.where((badge) {
                    return badge.badgeName.toLowerCase().contains(query) ||
                        badge.badgeLevel.toLowerCase().contains(query) ||
                        badge.username.toLowerCase().contains(query) ||
                        badge.badgeId.toLowerCase().contains(query);
                  }).toList();
        
                  if (filteredBadges.isEmpty) {
                    return const Center(child: Text('No badges found'));
                  }
        
                  return RefreshIndicator(
                    onRefresh: () async {
                      _retryFetch();
                      await _badgesFuture;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredBadges.length,
                      itemBuilder: (context, index) {
                        final badge = filteredBadges[index];
                        final deletingKey =
                            badge.rowId.isNotEmpty ? badge.rowId : badge.badgeId;
        
                        return ShowBadgeListTile(
                          badge: badge,
                          isDeleting: _deletingBadgeKey == deletingKey,
                          errorColor: customColors.error,
                          onEdit: () async {
                            final shouldRefresh = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditBadgePage(
                                  badge: DSVBadge(
                                    badgeLevel: badge.badgeLevel,
                                    badgeName: badge.badgeName,
                                    badgeLogo: badge.badgeLogo,
                                    badgeId: badge.badgeId,
                                    rowId: badge.rowId,
                                  ),
                                ),
                              ),
                            );
        
                            if (shouldRefresh == true) {
                              _retryFetch();
                            }
                          },
                          onDelete: () {
                            showWarningDialogueBox<bool>(
                              context: context,
                              title: 'Delete Badge',
                              subtitle: 'Are you sure you want to delete this badge?',
                              primaryText: 'Delete',
                            ).then((confirmed) {
                              if (confirmed == true) {
                                _deleteBadge(badge);
                              }
                            });
                          },
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
  }
}
