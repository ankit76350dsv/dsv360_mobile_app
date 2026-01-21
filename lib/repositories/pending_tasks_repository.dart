import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/task.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_tasks_repository.g.dart';

@riverpod
class PendingTasksListRepository extends _$PendingTasksListRepository {
  @override
  Future<List<Task>> build(String userId) async {
    return fetchPendingTasks(userId);
  }

  Future<List<Task>> fetchPendingTasks(String userId) async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/employees/$userId',
      );
      debugPrint("Response From fetchPendingTasks: $response");

      final data = response.data;
      final List<dynamic> list = data["data"];
      final pendingTasksList = list.map((e) {
        final taskJson = e['Tasks'] as Map<String, dynamic>;
        return Task.fromJson(taskJson);
      }).toList();

      return pendingTasksList;
    } catch (e, st) {
      developer.log(
        "Error fetching Pending Tasks: $e",
        name: "PendingTasksListRepository",
      );
      throw AsyncError(e, st);
    }
  }
}