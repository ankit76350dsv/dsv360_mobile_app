import 'dart:developer' as developer;

import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';

class FetchTasksByProjectAndUserRepository {
  final _client = ApiClient.instance;

  Future<List<Task>> fetchTasksByProjectAndUser(
    String projectId,
    String userId,
  ) async {
    try {
      const path =
          'time_entry_management_application_function/taskByProjectAndUser';
      final response = await _client.get(
        path,
        queryParameters: {"projectId": projectId, "userId": userId},
      );
      debugPrint(
        "Response From fetchTasksByProjectAndUser: ${response.statusCode}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse =
            response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final List<dynamic> list = jsonResponse["data"] ?? [];
          return list
              .map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      developer.log(
        "Error fetching tasks by project and user: $e",
        name: "FetchTasksByProjectAndUserRepository",
      );
      return [];
    }
  }
}
