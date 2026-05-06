import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/create_sprint_model.dart';
import 'package:dsv360/features/sprints/model/sprints_model.dart';

class SprintRepository {
  Future<List<SprintModel>> fetchSprints({required String projectId}) async {
    final response = await ApiClient.instance.get(
      'sprints_management_function/sprints?projectId=$projectId',
    );

    final data = response.data;
    List<dynamic> rawList = [];
    if (data is Map && data['data'] is List) {
      rawList = data['data'];
    } else if (data is List) {
      rawList = data;
    }

    return rawList
        .whereType<Map>()
        .map((e) => SprintModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<CreateSprintModel> createSprint({
    required String sprintName,
    required String goal,
    required String projectId,
    required String startDate,
    required String endDate,
    String status = 'ACTIVE',
  }) async {
    final payload = {
      'SprintName': sprintName,
      'Goal': goal,
      'ProjectID': projectId,
      'StartDate': startDate,
      'EndDate': endDate,
      'Status': status,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/sprints',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return CreateSprintModel.fromJson(Map<String, dynamic>.from(data['data']));
    }
    throw Exception('Invalid create sprint response');
  }

  Future<Map<String, dynamic>> completeSprint({
    required String sprintId,
    required String carryOverSprintId,
  }) async {
    final response = await ApiClient.instance.post(
      'sprints_management_function/sprints/$sprintId/complete',
      data: {'carryOverSprintId': carryOverSprintId},
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception('Invalid complete sprint response');
  }
}
