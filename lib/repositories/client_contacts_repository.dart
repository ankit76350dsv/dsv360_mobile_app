import 'package:dsv360/models/client_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientContactsRepository extends AsyncNotifier<List<ClientContacts>> {
  @override
  Future<List<ClientContacts>> build() async {
    return fetchClientContactsList(isInitial: true) ?? [];
  }

  Future<List<ClientContacts>> fetchClientContactsList({
    bool isInitial = false,
  }) async {
    return [];
  }
}

final clientContactsListRepositoryProvider = 
Provider<AsyncValue<List<ClientContacts>>>(
  (ref) {
    final contactsList = <ClientContacts>[
    ClientContacts.fromJson({
      "CREATORID": "17682000000037258",
      "First_Name": "Abhay",
      "Last_Name": "Singh Patel",
      "Org_Name": "Skyii",
      "OrgID": "17682000000045197",
      "UserID": "17682000000048171",
      "Email": "abhaysinghpatel0920@gmail.com",
      "Phone": "9984237401",
      "MODIFIEDTIME": "2026-01-06 23:17:12:593",
      "CREATEDTIME": "2025-05-09 15:32:50:503",
      "ROWID": "17682000000045244",
      "status": true,
    }),
    ClientContacts.fromJson({
      "CREATORID": "17682000000037259",
      "First_Name": "Rohit",
      "Last_Name": "Sharma",
      "Org_Name": "Skyii",
      "OrgID": "17682000000045197",
      "UserID": "17682000000048172",
      "Email": "rohit.sharma@skyii.com",
      "Phone": "9876543210",
      "MODIFIEDTIME": "2026-01-05 11:12:45:220",
      "CREATEDTIME": "2025-06-01 10:22:18:110",
      "ROWID": "17682000000045245",
      "status": true,
    }),
    ClientContacts.fromJson({
      "CREATORID": "17682000000037260",
      "First_Name": "Neha",
      "Last_Name": "Verma",
      "Org_Name": "BlueTech",
      "OrgID": "17682000000045198",
      "UserID": "17682000000048173",
      "Email": "neha.verma@bluetech.com",
      "Phone": "9123456789",
      "MODIFIEDTIME": "2026-01-04 09:30:12:987",
      "CREATEDTIME": "2025-04-18 14:45:00:321",
      "ROWID": "17682000000045246",
      "status": false,
    }),
    ClientContacts.fromJson({
      "CREATORID": "17682000000037261",
      "First_Name": "Amit",
      "Last_Name": "Kumar",
      "Org_Name": "NextGen Labs",
      "OrgID": "17682000000045199",
      "UserID": "17682000000048174",
      "Email": "amit.kumar@nextgenlabs.ai",
      "Phone": "9012345678",
      "MODIFIEDTIME": "2026-01-03 16:10:55:777",
      "CREATEDTIME": "2025-03-22 08:40:10:654",
      "ROWID": "17682000000045247",
      "status": true,
    }),
  ];

  return AsyncValue.data(contactsList);
  },
);

final clientContactsSearchQueryProvider = StateProvider<String>((ref) => '');
