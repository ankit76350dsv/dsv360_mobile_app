import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/story_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createStoryRepositoryProvider = Provider<CreateStoryRepository>((ref) {
  return CreateStoryRepository();
});

class CreateStoryRepository {
  Future<StoryModel> createStory({
    required String title,
    required String projectId,
    required String sprintId,
    String? description,
    String? epicId,
    String? assigneeId,
    String? primaryOwnership,
    String? secondaryOwnership,
    String status = 'NOT_STARTED',
    int points = 3,
    String priority = 'MEDIUM',
    String? billingType,
    String? requirementType,
    String? moduleName,
    String? groupName,
    String? zohoProductName,
    String? fiRemarks,
    String? clientRemarks,
  }) async {
    final payload = {
      "Title": title,
      "ProjectID": projectId,
      "SprintID": sprintId,
      "Description": description ?? '',
      "EpicID": epicId ?? '',
      "AssigneeID": assigneeId ?? '',
      "PrimaryOwnership": primaryOwnership ?? '',
      "SecondaryOwnership": secondaryOwnership ?? '',
      "Status": status,
      "Points": points,
      "Priority": priority,
      "BillingType": billingType ?? '',
      "RequirementType": requirementType ?? '',
      "ModuleName": moduleName ?? '',
      "GroupName": groupName ?? '',
      "ZohoProductName": zohoProductName ?? '',
      "FIRemarks": fiRemarks ?? '',
      "ClientRemarks": clientRemarks ?? '',
    };

    

    final response = await ApiClient.instance.post(
      'sprints_management_function/stories',
      data: payload,
    );

    final data = response.data;

    if (data is Map && data['data'] != null) {
      return StoryModel.fromJson(Map<String, dynamic>.from(data['data']));
    } else {
      throw Exception('Something went wrong');
    }
  }
}
