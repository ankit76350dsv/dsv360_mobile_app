import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/create_release_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createReleaseRepositoryProvider = Provider<CreateReleaseRepository>((
  ref,
) {
  return CreateReleaseRepository();
});

class CreateReleaseRepository {
  Future<CreateReleaseModel> createRelease({
    required String title,
    required String projctID,
    required String description,
    required String dueDate,
  }) async {
    final payload = {
      "Title": title,
      "Description": description,
      "DueDate": dueDate,
      "ProjectID": projctID,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/milestones',
      data: payload,
    );

    final data = response.data;

    if (data is Map && data['data'] != null) {
      return CreateReleaseModel.fromJson(
        Map<String, dynamic>.from(data['data']),
      );
    } else {
      throw Exception('Invalid create release response');
    }
  }
}
