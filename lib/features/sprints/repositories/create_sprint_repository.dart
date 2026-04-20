import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/create_sprint_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createSprintRepositoryProvider =
    Provider<CreateSprintRepository>((ref) {
  return CreateSprintRepository();
});

class CreateSprintRepository {
  Future<CreateSprintModel> createSprint({
    required String sprintName,
    required String goal,
    required String projectId,
    required String startDate,
    required String endDate,
    String status = "ACTIVE",
  }) async {
    final payload = {
      "SprintName": sprintName,
      "Goal": goal,
      "ProjectID": projectId,
      "StartDate": startDate,
      "EndDate": endDate,
      "Status": status,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/sprints',
      data: payload,
    );

    final data = response.data;

    if (data is Map && data['data'] != null) {
      return CreateSprintModel.fromJson(
        Map<String, dynamic>.from(data['data']),
      );
    } else {
      throw Exception('Invalid create sprint response');
    }
  }
}