import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteTaskRepository {
  final _client = ApiClient.instance;

  Future<void> deleteTask(String rowId) async {
    try {
      final path =
          'time_entry_management_application_function/tasks/$rowId';
      final response = await _client.delete(path);
      debugPrint("Response From deleteTask: ${response.statusCode}");
      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e, st) {
      developer.log(
        "Error deleting task: $e",
        name: "DeleteTaskRepository",
      );
      throw AsyncError(e, st);
    }
  }
}
