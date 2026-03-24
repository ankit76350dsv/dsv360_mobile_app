import 'package:dsv360/features/badges/model/dsvbadge.dart';
import 'package:dsv360/features/badges/repositories/badge_catalog_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addEditBadgeViewModelProvider = Provider<AddEditBadgeViewModel>((ref) {
  return AddEditBadgeViewModel(ref.read(badgeCatalogRepositoryProvider));
});

class AddEditBadgeViewModel {
  AddEditBadgeViewModel(this._catalogRepository);

  final BadgeCatalogRepository _catalogRepository;

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
    final isEditing = badge != null;

    if (isEditing) {
      await _catalogRepository.updateBadge(rowId: badge.rowId, body: body);
    } else {
      await _catalogRepository.createBadge(body);
    }

    if (!context.mounted) return;
    Navigator.pop(context, true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'Badge updated successfully' : 'Badge added successfully',
        ),
      ),
    );
  }
}
