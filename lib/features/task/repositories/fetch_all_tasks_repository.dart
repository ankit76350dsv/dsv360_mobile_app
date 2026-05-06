import 'dart:developer' as developer;

import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';

class FetchAllTasksRepository {
  final _client = ApiClient.instance;

  Future<List<Task>> fetchAllTasks() async {
    try {
      const path = 'time_entry_management_application_function/tasks';
      final response = await _client.get(path);
      debugPrint("Response From fetchAllTasks: ${response.statusCode}");

      if (response.statusCode == 200) {
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
        "Error fetching all tasks: $e",
        name: "FetchAllTasksRepository",
      );
      return [];
    }
  }
}
