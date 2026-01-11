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
      "DSVBadge_Level": "Bronze",
      "DSVBadge_Name": "BFSI",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Bronze-min.png",
      "DSVBadge_ID": "BFSI_BRZ",
      "ROWID": "17682000000302395",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Diamond",
      "DSVBadge_Name": "BFSI",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Diamond-min.png",
      "DSVBadge_ID": "BFSI_DMD",
      "ROWID": "17682000000302846",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Platinum",
      "DSVBadge_Name": "BFSI",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Platinium-min.png",
      "DSVBadge_ID": "BFSI_PLT",
      "ROWID": "17682000000302849",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Titanium",
      "DSVBadge_Name": "Titanium_test",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Titanium-min.png",
      "DSVBadge_ID": "Tt_test",
      "ROWID": "17682000000302858",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Gold",
      "DSVBadge_Name": "Gold-Test",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/GOLD-min.png",
      "DSVBadge_ID": "Gd-test",
      "ROWID": "17682000000302864",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Silver",
      "DSVBadge_Name": "Silver-Test",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Silver-min.png",
      "DSVBadge_ID": "Silver-test",
      "ROWID": "17682000000302867",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Silver",
      "DSVBadge_Name": "Broze_Dsd",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Silver-min.png",
      "DSVBadge_ID": "adsadsa",
      "ROWID": "17682000000302874",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Platinum",
      "DSVBadge_Name": "adasdsa22",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Platinium-min.png",
      "DSVBadge_ID": "Pt_Test2",
      "ROWID": "17682000000302877",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Bronze",
      "DSVBadge_Name": "Broze_Dsd22",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Bronze-min.png",
      "DSVBadge_ID": "asdsa",
      "ROWID": "17682000000302883",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Titanium",
      "DSVBadge_Name": "BFSI",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Titanium-min.png",
      "DSVBadge_ID": "BFSI_TITAN",
      "ROWID": "17682000000302976",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Bronze",
      "DSVBadge_Name": "bfsi",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Bronze-min.png",
      "DSVBadge_ID": "bfsi_brz",
      "ROWID": "17682000000310139",
    }),
    DSVBadge.fromJson({
      "DSVBadge_Level": "Titanium",
      "DSVBadge_Name": "Test_DSVBadges",
      "DSVBadge_Logo":
          "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Titanium-min.png",
      "DSVBadge_ID": "Test_001",
      "ROWID": "17682000000331718",
    }),
  ];

  return AsyncValue.data(dsvBadges);
});
