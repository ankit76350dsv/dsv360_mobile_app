import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:dsv360/features/badges/model/dsvbadge.dart';
import 'package:dsv360/features/badges/repositories/assign_badge_repository.dart';
import 'package:dsv360/features/badges/repositories/fetch_badge_users_repository.dart';
import 'package:dsv360/features/badges/repositories/fetch_badges_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assignBadgesViewModelProvider = Provider<AssignBadgesViewModel>((ref) {
  return AssignBadgesViewModel(
    fetchUsersRepository: ref.read(fetchBadgeUsersRepositoryProvider),
    fetchBadgesRepository: ref.read(fetchBadgesRepositoryProvider),
    assignRepository: ref.read(assignBadgeRepositoryProvider),
  );
});

class AssignBadgesViewModel {
  AssignBadgesViewModel({
    required this.fetchUsersRepository,
    required this.fetchBadgesRepository,
    required this.assignRepository,
  });

  final FetchBadgeUsersRepository fetchUsersRepository;
  final FetchBadgesRepository fetchBadgesRepository;
  final AssignBadgeRepository assignRepository;

  Future<List<BadgeUser>> fetchUsers() {
    return fetchUsersRepository.fetchUsers();
  }

  Future<List<DSVBadge>> fetchBadges() {
    return fetchBadgesRepository.fetchAllBadgesForAssign();
  }

  Future<void> assignBadge({
    required BuildContext context,
    required Map<String, dynamic> payload,
  }) async {
    await assignRepository.assignBadge(payload);

    if (!context.mounted) return;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Badge assigned successfully')),
    );
  }
}
