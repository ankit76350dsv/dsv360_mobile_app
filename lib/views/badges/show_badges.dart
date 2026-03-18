import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:dsv360/views/widgets/custom_input_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final showBadgesSearchQueryProvider = StateProvider<String>((ref) => '');

class ShowBadgesPage extends ConsumerStatefulWidget {
  const ShowBadgesPage({super.key});

  @override
  ConsumerState<ShowBadgesPage> createState() => _ShowBadgesPageState();
}

class _ShowBadgesPageState extends ConsumerState<ShowBadgesPage> {
  late Future<List<_BadgeItem>> _badgesFuture;

  

  @override
  void initState() {
    super.initState();
    _badgesFuture = _fetchBadges();
  }

  Future<List<_BadgeItem>> _fetchBadges() async {
    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/badge/',
    );
    return _parseBadges(response.data);
  }

  List<_BadgeItem> _parseBadges(dynamic data) {
    final dynamic rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'];
    } else {
      rawList = const [];
    }

    return (rawList as List)
        .whereType<Map>()
        .map((e) => _BadgeItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
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
      appBar: AppBar(
        title: const Text('All Badges'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: CustomInputSearch(
              hint: 'Search badges',
              searchProvider: showBadgesSearchQueryProvider,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<_BadgeItem>>(
              future: _badgesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: DsvLoader());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Failed to load badges: ${snapshot.error}',
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

                final badges = snapshot.data ?? const <_BadgeItem>[];
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

                      return Card(
                        elevation: 3,
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade100,
                            child: Image.network(
                              badge.badgeLogo,
                              width: 56,
                              height: 56,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.emoji_events_outlined,
                                size: 32,
                              ),
                            ),
                          ),
                          title: Text(
                            badge.badgeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${badge.badgeLevel} • ${badge.badgeId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomCardButton(
                                onTap: () {
                                  // update badge
                                  
                                },
                                icon: Icons.edit,
                              ),
                              const SizedBox(width: 5.0),
                              CustomCardButton(
                                onTap: () {
                                  // delete badge
                                },
                                icon: Icons.delete,
                                color: customColors.error,
                              ),
                            ],
                          ),
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
    );
  }
}

class _BadgeItem {
  final String badgeId;
  final String badgeName;
  final String badgeLevel;
  final String badgeLogo;
  final String username;

  const _BadgeItem({
    required this.badgeId,
    required this.badgeName,
    required this.badgeLevel,
    required this.badgeLogo,
    required this.username,
  });

  factory _BadgeItem.fromJson(Map<String, dynamic> json) {
    return _BadgeItem(
      badgeId: (json['Badge_ID'] ?? '').toString(),
      badgeName: (json['Badge_Name'] ?? '').toString(),
      badgeLevel: (json['Badge_Level'] ?? '').toString(),
      badgeLogo: (json['Badge_Logo'] ?? '').toString(),
      username: (json['Username'] ?? '').toString(),
    );
  }
}