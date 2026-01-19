import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/models/dsvbadge.dart';

class AllDSVBadgesList extends AsyncNotifier<List<DSVBadge>> {
  @override
  FutureOr<List<DSVBadge>> build() async {
    // TODO: implement build
    return fetchAllDSVBadgesList(isInitial: true) ?? [];
  }

  FutureOr<List<DSVBadge>> fetchAllDSVBadgesList({bool isInitial = false}) async {
    return [];
  }
}
final allDSVBadgesListRepositoryProvider =
    Provider<AsyncValue<List<DSVBadge>>>((ref) {
  final dsvBadges = <DSVBadge>[
    DSVBadge.fromJson({
      "Badge_Level": "Bronze",
      "Badge_Name": "BFSI",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Bronze-min.png",
      "Badge_ID": "BFSI_BRZ",
      "ROWID": "17682000000302395",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Diamond",
      "Badge_Name": "BFSI",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Diamond-min.png",
      "Badge_ID": "BFSI_DMD",
      "ROWID": "17682000000302846",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Platinum",
      "Badge_Name": "BFSI",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Platinium-min.png",
      "Badge_ID": "BFSI_PLT",
      "ROWID": "17682000000302849",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Titanium",
      "Badge_Name": "Titanium_test",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Titanium-min.png",
      "Badge_ID": "Tt_test",
      "ROWID": "17682000000302858",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Gold",
      "Badge_Name": "Gold-Test",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/GOLD-min.png",
      "Badge_ID": "Gd-test",
      "ROWID": "17682000000302864",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Silver",
      "Badge_Name": "Silver-Test",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Silver-min.png",
      "Badge_ID": "Silver-test",
      "ROWID": "17682000000302867",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Silver",
      "Badge_Name": "Broze_Dsd",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Silver-min.png",
      "Badge_ID": "adsadsa",
      "ROWID": "17682000000302874",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Platinum",
      "Badge_Name": "adasdsa22",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Platinium-min.png",
      "Badge_ID": "Pt_Test2",
      "ROWID": "17682000000302877",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Bronze",
      "Badge_Name": "Broze_Dsd22",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Bronze-min.png",
      "Badge_ID": "asdsa",
      "ROWID": "17682000000302883",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Titanium",
      "Badge_Name": "BFSI",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Titanium-min.png",
      "Badge_ID": "BFSI_TITAN",
      "ROWID": "17682000000302976",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Bronze",
      "Badge_Name": "bfsi",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Bronze-min.png",
      "Badge_ID": "bfsi_brz",
      "ROWID": "17682000000310139",
    }),
    DSVBadge.fromJson({
      "Badge_Level": "Titanium",
      "Badge_Name": "Test_DSVBadges",
      "Badge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Titanium-min.png",
      "Badge_ID": "Test_001",
      "ROWID": "17682000000331718",
    }),
  ];

  return AsyncValue.data(dsvBadges);
});
