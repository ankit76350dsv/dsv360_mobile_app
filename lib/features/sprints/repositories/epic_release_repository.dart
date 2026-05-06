import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/create_release_model.dart';
import 'package:dsv360/features/sprints/model/epic_model.dart';

class EpicReleaseRepository {
  Future<EpicModel> createEpic({
    required String title,
    required String description,
    required String projectId,
    required String milestoneId,
    required String color,
  }) async {
    final payload = {
      'Title': title,
      'Description': description,
      'ProjectID': projectId,
      'Color': color,
      'MilestoneID': milestoneId,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/epics',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return EpicModel.fromJson(Map<String, dynamic>.from(data['data']));
    }
    throw Exception('Something went wrong');
  }

  Future<CreateReleaseModel> createRelease({
    required String title,
    required String projctID,
    required String description,
    required String dueDate,
  }) async {
    final payload = {
      'Title': title,
      'Description': description,
      'DueDate': dueDate,
      'ProjectID': projctID,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/milestones',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return CreateReleaseModel.fromJson(Map<String, dynamic>.from(data['data']));
    }
    throw Exception('Invalid create release response');
  }
}
