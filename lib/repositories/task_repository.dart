import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_repository.g.dart';

@riverpod
class TasksListRepository extends _$TasksListRepository {
  @override
  Future<List<Task>> build(String userId) async {
    return fetchTasks(userId);
  }

  Future<List<Task>> fetchTasks(String userId) async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/emp/$userId',
      );
      debugPrint("Response From fetchTasks: $response");

      final data = response.data;
      final List<dynamic> list = data["data"];
      final tasksList = list.map((e) {
        final taskJson = e['Tasks'] as Map<String, dynamic>;
        return Task.fromJson(taskJson);
      }).toList();

      return tasksList;
    } catch (e, st) {
      developer.log(
        "Error fetching tasks: $e",
        name: "TasksListRepository",
      );
      throw AsyncError(e, st);
    }
  }
}