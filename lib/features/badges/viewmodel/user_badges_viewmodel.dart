import 'package:dsv360/features/badges/model/assigned_badge.dart';
import 'package:dsv360/features/badges/repositories/badge_assignment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userBadgesViewModelProvider = Provider<UserBadgesViewModel>((ref) {
  return UserBadgesViewModel(ref.read(badgeAssignmentRepositoryProvider));
});

class UserBadgesViewModel {
  UserBadgesViewModel(this._assignmentRepository);

  final BadgeAssignmentRepository _assignmentRepository;

  Future<List<AssignedBadge>> fetchUserBadges(String userId) {
    return _assignmentRepository.fetchUserBadges(userId);
  }

  Future<void> deleteAssignedBadge(String rowId) {
    return _assignmentRepository.deleteAssignedBadges([rowId]);
  }
}
