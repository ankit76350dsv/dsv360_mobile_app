import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:dsv360/features/badges/model/dsvbadge.dart';
import 'package:dsv360/features/badges/repositories/badge_assignment_repository.dart';
import 'package:dsv360/features/badges/repositories/badge_catalog_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assignBadgesViewModelProvider = Provider<AssignBadgesViewModel>((ref) {
  return AssignBadgesViewModel(
    assignmentRepository: ref.read(badgeAssignmentRepositoryProvider),
    catalogRepository: ref.read(badgeCatalogRepositoryProvider),
  );
});

class AssignBadgesViewModel {
  AssignBadgesViewModel({
    required BadgeAssignmentRepository assignmentRepository,
    required BadgeCatalogRepository catalogRepository,
  }) : _assignmentRepository = assignmentRepository,
       _catalogRepository = catalogRepository;

  final BadgeAssignmentRepository _assignmentRepository;
  final BadgeCatalogRepository _catalogRepository;

  Future<List<BadgeUser>> fetchUsers() {
    return _assignmentRepository.fetchUsers();
  }

  Future<List<DSVBadge>> fetchBadges() {
    return _catalogRepository.fetchAllBadgesForAssign();
  }

  Future<void> assignBadge({
    required BuildContext context,
    required Map<String, dynamic> payload,
  }) async {
    await _assignmentRepository.assignBadge(payload);

    if (!context.mounted) return;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Badge assigned successfully')),
    );
  }
}
