import 'package:dsv360/features/badges/model/assigned_badge.dart';
import 'package:dsv360/features/badges/repositories/badge_repository.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';

final userBadgesViewModelProvider = Provider<UserBadgesViewModel>((ref) {
  return UserBadgesViewModel(
    fetchRepository: ref.read(fetchUserBadgesRepositoryProvider),
    deleteRepository: ref.read(deleteAssignedBadgesRepositoryProvider),
  );
});

class UserBadgesViewModel {
  UserBadgesViewModel({
    required this.fetchRepository,
    required this.deleteRepository,
  });

  final BadgeRepository fetchRepository;
  final BadgeRepository deleteRepository;

  Future<List<AssignedBadge>> fetchUserBadges(String userId) {
    return fetchRepository.fetchUserBadges(userId);
  }

  Future<void> deleteAssignedBadge(String rowId) {
    return deleteRepository.deleteAssignedBadges([rowId]);
  }
}
