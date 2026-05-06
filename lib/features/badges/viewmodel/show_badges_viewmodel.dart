import 'package:dsv360/features/badges/model/badge_summary.dart';
import 'package:dsv360/features/badges/repositories/badge_repository.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';

final showBadgesSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final showBadgesViewModelProvider = Provider<ShowBadgesViewModel>((ref) {
  return ShowBadgesViewModel(
    fetchRepository: ref.read(fetchBadgesRepositoryProvider),
    deleteRepository: ref.read(deleteBadgeRepositoryProvider),
  );
});

class ShowBadgesViewModel {
  ShowBadgesViewModel({
    required this.fetchRepository,
    required this.deleteRepository,
  });

  final BadgeRepository fetchRepository;
  final BadgeRepository deleteRepository;

  Future<List<BadgeSummary>> fetchBadges() {
    return fetchRepository.fetchAllBadgesForList();
  }

  Future<void> deleteBadge(BadgeSummary badge) {
    final deleteId = badge.rowId.isNotEmpty ? badge.rowId : badge.badgeId;
    return deleteRepository.deleteBadge(deleteId: deleteId);
  }
}
