import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/epic_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final createEpicRepositoryProvider = Provider<CreateEpicRepository>((ref,){
  return CreateEpicRepository();
});
class CreateEpicRepository {
  Future<EpicModel> createEpic({
    required String title,
    required String description,
    required String projectId,
    required String milestoneId,
    required String color,
  }) async {
    final payload = {
      "Title": title,
      "Description": description,
      "ProjectID": projectId,
      "Color": color,
      "MilestoneID": milestoneId,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/epics',
      data: payload,
    );

    final data = response.data;

    if (data is Map && data['data'] != null) {
      return EpicModel.fromJson(Map<String, dynamic>.from(data['data']));
    } else {
      throw Exception('Something went worng');
    }
  }
}
