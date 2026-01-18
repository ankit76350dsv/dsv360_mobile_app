import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersRepository extends AsyncNotifier<List<UsersModel>> {
  @override
  FutureOr<List<UsersModel>> build() async {
    return await fetchUsers(isInitial: true);
  }

  Future<List<UsersModel>> fetchUsers({bool isInitial = false}) async {
    try {
      final response = await DioClient.instance.get(
        '/server/time_entry_management_application_function/employee',
      );
      debugPrint("Response From fetchUsers: $response");

      final data = response.data;
      final List<dynamic> list = data["users"];
      final usersList = list.map((e) => UsersModel.fromJson(e)).toList();

      return usersList;
    } catch (e, st) {
      developer.log(
        "Error fetching users: $e",
        name: "UsersRepository",
      );
      throw AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetchUsers);
  }
}

final usersRepositoryProvider =
    AsyncNotifierProvider<UsersRepository, List<UsersModel>>(
  UsersRepository.new,
);

// final usersRepositoryProvider = Provider<AsyncValue<List<UsersModel>>>((ref) {
//   // Simulate API data
//   final users = <UsersModel>[
//     UsersModel(
//       firstName: "Aman",
//       lastName: "Jain",
//       userId: "U5367",
//       emailAddress: "aman.jain@example.com",
//       role: "Admin",
//       profilePic:
//           "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
//       workStatus: WorkStatus.active,
//       verificationStatus: VerificationStatus.verified,
//     ),
//     UsersModel(
//       firstName: "Adsadas",
//       lastName: "Patel",
//       userId: "U4243",
//       emailAddress: "adsadas.patel@example.com",
//       role: "Intern",
//       profilePic:
//           "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
//       workStatus: WorkStatus.inactive,
//       verificationStatus: VerificationStatus.pending,
//     ),
//     UsersModel(
//       firstName: "Kaushal",
//       lastName: "Kishor",
//       userId: "U1227",
//       emailAddress: "kaushal.kishor@example.com",
//       role: "Manager",
//       profilePic:
//           "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
//       workStatus: WorkStatus.active,
//       verificationStatus: VerificationStatus.verified,
//     ),
//     UsersModel(
//       firstName: "Employee",
//       lastName: "Singh",
//       userId: "U3172",
//       emailAddress: "employee.singh@example.com",
//       role: "Intern",
//       profilePic:
//           "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
//       workStatus: WorkStatus.active,
//       verificationStatus: VerificationStatus.verified,
//     ),
//     UsersModel(
//       firstName: "Abhay",
//       lastName: "",
//       userId: "U4167",
//       emailAddress: "abhay@example.com",
//       role: "Manager/Team Lead",
//       profilePic:
//           "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
//       workStatus: WorkStatus.inactive,
//       verificationStatus: VerificationStatus.pending,
//     ),
//     UsersModel(
//       firstName: "Ujjwal",
//       lastName: "Mishra",
//       userId: "U4027",
//       emailAddress: "ujjwal.mishra@example.com",
//       role: "Business Analyst",
//       profilePic:
//           "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
//       workStatus: WorkStatus.active,
//       verificationStatus: VerificationStatus.verified,
//     ),
//   ];

//   return AsyncValue.data(users);
// });

final usersSearchQueryProvider = StateProvider<String>((ref) => '');
