import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/heirarchy_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hierarchyRepositoryProvider = Provider<HierarchyRepository>((ref) {
  return HierarchyRepository();
});

class HierarchyRepository {
  Future<HierarchyModel> fetchHierarchy({
    required String projectId,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await ApiClient.instance.get(
      'sprints_management_function/hierarchy'
      '?projectId=$projectId&page=$page&limit=$limit',
    );

    final data = response.data;

    if (data is Map) {
      return HierarchyModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Invalid hierarchy response format');
  }
}