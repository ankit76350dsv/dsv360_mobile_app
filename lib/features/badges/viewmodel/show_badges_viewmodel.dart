import 'package:dsv360/features/badges/model/badge_summary.dart';
import 'package:dsv360/features/badges/repositories/badge_catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final showBadgesSearchQueryProvider = StateProvider<String>((ref) => '');

final showBadgesViewModelProvider = Provider<ShowBadgesViewModel>((ref) {
  return ShowBadgesViewModel(ref.read(badgeCatalogRepositoryProvider));
});

class ShowBadgesViewModel {
  ShowBadgesViewModel(this._catalogRepository);

  final BadgeCatalogRepository _catalogRepository;

  Future<List<BadgeSummary>> fetchBadges() {
    return _catalogRepository.fetchAllBadgesForList();
  }

  Future<void> deleteBadge(BadgeSummary badge) {
    final deleteId = badge.rowId.isNotEmpty ? badge.rowId : badge.badgeId;
    return _catalogRepository.deleteBadge(deleteId: deleteId);
  }
}
