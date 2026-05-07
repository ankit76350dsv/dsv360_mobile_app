import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/features/badges/model/assigned_badge.dart';
import 'package:dsv360/features/badges/model/badge_summary.dart';
import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:dsv360/features/badges/model/dsvbadge.dart';
import 'package:dsv360/features/badges/repositories/badge_repository.dart';
import 'package:dsv360/features/badges/viewmodel/badge_image_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Add / Edit Badge ──────────────────────────────────────────────────────────

final addEditBadgeViewModelProvider = Provider<AddEditBadgeViewModel>((ref) {
  return AddEditBadgeViewModel(ref.read(badgeRepositoryProvider));
});

class AddEditBadgeViewModel {
  AddEditBadgeViewModel(this._repository);

  final BadgeRepository _repository;

  static const Map<String, String> badgeLevelLogoMap = {
    'Bronze': 'https://dsv365-development.zohostratus.in/dsv365/Badges/Bronze-min.png',
    'Silver': 'https://dsv365-development.zohostratus.in/dsv365/Badges/Silver-min.png',
    'Gold': 'https://dsv365-development.zohostratus.in/dsv365/Badges/GOLD-min.png',
    'Diamond': 'https://dsv365-development.zohostratus.in/dsv365/Badges/Diamond-min.png',
    'Platinum': 'https://dsv365-development.zohostratus.in/dsv365/Badges/Platinium-min.png',
    'Titanium': 'https://dsv365-development.zohostratus.in/dsv365/Badges/Titanium-min.png',
  };

  String? normalizeBadgeLevel(String? rawLevel) {
    if (rawLevel == null || rawLevel.trim().isEmpty) return null;
    final value = rawLevel.toLowerCase().trim();
    if (value.contains('platinium')) return 'Platinum';
    for (final level in badgeLevelLogoMap.keys) {
      if (value == level.toLowerCase() || value.contains(level.toLowerCase())) {
        return level;
      }
    }
    return null;
  }

  Map<String, dynamic> buildRequestBody({
    required String badgeId,
    required String badgeName,
    required String? badgeLevel,
    required String? badgeLogo,
  }) {
    return {
      'Badge_ID': badgeId.trim(),
      'Badge_Name': badgeName.trim(),
      'Badge_Level': badgeLevel,
      'Badge_Logo': badgeLogo,
    };
  }

  Future<void> submitBadge({
    required BuildContext context,
    required DSVBadge? badge,
    required Map<String, dynamic> body,
  }) async {
    if (badge != null) {
      await _repository.updateBadge(rowId: badge.rowId, body: body);
    } else {
      await _repository.createBadge(body);
    }
    if (!context.mounted) return;
    Navigator.pop(context, true);
    
    showSuccessSnackBar(context, badge != null ? 'Badge updated successfully' : 'Badge added successfully');
  }
}

// ── Show / Delete Badges ──────────────────────────────────────────────────────

final showBadgesSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final showBadgesViewModelProvider = Provider<ShowBadgesViewModel>((ref) {
  return ShowBadgesViewModel(ref.read(badgeRepositoryProvider));
});

class ShowBadgesViewModel {
  ShowBadgesViewModel(this._repository);

  final BadgeRepository _repository;

  Future<List<BadgeSummary>> fetchBadges() => _repository.fetchAllBadgesForList();

  Future<void> deleteBadge(BadgeSummary badge) {
    final deleteId = badge.rowId.isNotEmpty ? badge.rowId : badge.badgeId;
    return _repository.deleteBadge(deleteId: deleteId);
  }
}

// ── Assign Badges ─────────────────────────────────────────────────────────────

final assignBadgesViewModelProvider = Provider<AssignBadgesViewModel>((ref) {
  return AssignBadgesViewModel(ref.read(badgeRepositoryProvider));
});

class AssignBadgesViewModel {
  AssignBadgesViewModel(this._repository);

  final BadgeRepository _repository;

  Future<List<BadgeUser>> fetchUsers() => _repository.fetchUsers();

  Future<List<DSVBadge>> fetchBadges() => _repository.fetchAllBadgesForAssign();

  Future<void> assignBadge({
    required BuildContext context,
    required Map<String, dynamic> payload,
  }) async {
    await _repository.assignBadge(payload);
    if (!context.mounted) return;
    Navigator.pop(context, true);
    
    showSuccessSnackBar(context, 'Badge assigned successfully');
  }
}

// ── User Badges ───────────────────────────────────────────────────────────────

final userBadgesViewModelProvider = Provider<UserBadgesViewModel>((ref) {
  return UserBadgesViewModel(ref.read(badgeRepositoryProvider));
});

class UserBadgesViewModel {
  UserBadgesViewModel(this._repository);

  final BadgeRepository _repository;

  Future<List<AssignedBadge>> fetchUserBadges(String userId) => _repository.fetchUserBadges(userId);

  Future<void> deleteAssignedBadge(String rowId) => _repository.deleteAssignedBadges([rowId]);
}
