import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/sprints_model.dart';

final getSprintsRepositoryProvider =
    Provider<GetSprintsRepository>((ref) {
  return GetSprintsRepository();
});

class GetSprintsRepository {
  Future<List<SprintModel>> fetchSprints({
    required String projectId,
  }) async {
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
        .map((e) => SprintModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }
}