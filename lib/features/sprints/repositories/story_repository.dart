import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/story_model.dart';

class StoryRepository {
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
      'Title': title,
      'ProjectID': projectId,
      'SprintID': sprintId,
      'Description': description ?? '',
      'EpicID': epicId ?? '',
      'AssigneeID': assigneeId ?? '',
      'PrimaryOwnership': primaryOwnership ?? '',
      'SecondaryOwnership': secondaryOwnership ?? '',
      'Status': status,
      'Points': points,
      'Priority': priority,
      'BillingType': billingType ?? '',
      'RequirementType': requirementType ?? '',
      'ModuleName': moduleName ?? '',
      'GroupName': groupName ?? '',
      'ZohoProductName': zohoProductName ?? '',
      'FIRemarks': fiRemarks ?? '',
      'ClientRemarks': clientRemarks ?? '',
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/stories',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return StoryModel.fromJson(Map<String, dynamic>.from(data['data']));
    }
    throw Exception('Something went wrong');
  }

  Future<StoryModel> editStory({
    required String storyId,
    String? title,
    String? description,
    String? epicId,
    String? sprintId,
    String? projectId,
    String? assigneeId,
    String? primaryOwnership,
    String? secondaryOwnership,
    String? status,
    int? points,
    String? priority,
    String? billingType,
    String? requirementType,
    String? moduleName,
    String? groupName,
    String? zohoProductName,
    String? fiRemarks,
    String? clientRemarks,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null) payload['Title'] = title;
    if (description != null) payload['Description'] = description;
    if (epicId != null) payload['EpicID'] = epicId;
    if (sprintId != null) payload['SprintID'] = sprintId;
    if (projectId != null) payload['ProjectID'] = projectId;
    if (assigneeId != null) payload['AssigneeID'] = assigneeId;
    if (primaryOwnership != null) payload['PrimaryOwnership'] = primaryOwnership;
    if (secondaryOwnership != null) payload['SecondaryOwnership'] = secondaryOwnership;
    if (status != null) payload['Status'] = status;
    if (points != null) payload['Points'] = points;
    if (priority != null) payload['Priority'] = priority;
    if (billingType != null) payload['BillingType'] = billingType;
    if (requirementType != null) payload['RequirementType'] = requirementType;
    if (moduleName != null) payload['ModuleName'] = moduleName;
    if (groupName != null) payload['GroupName'] = groupName;
    if (zohoProductName != null) payload['ZohoProductName'] = zohoProductName;
    if (fiRemarks != null) payload['FIRemarks'] = fiRemarks;
    if (clientRemarks != null) payload['ClientRemarks'] = clientRemarks;

    final response = await ApiClient.instance.patch(
      'sprints_management_function/stories/$storyId',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return StoryModel.fromJson(Map<String, dynamic>.from(data['data']));
    }
    throw Exception('Something went wrong');
  }

  Future<void> updateStatus({
    required String storyId,
    required String status,
  }) async {
    final response = await ApiClient.instance.patch(
      'sprints_management_function/stories/$storyId',
      data: {'Status': status},
    );

    final data = response.data;
    if (data is Map && data['success'] == true) return;
    throw Exception('Failed to update story status');
  }

  Future<void> deployToSprint({
    required String storyId,
    required String sprintId,
  }) async {
    final response = await ApiClient.instance.patch(
      'sprints_management_function/stories/$storyId',
      data: {'SprintID': sprintId},
    );

    final data = response.data;
    if (data is Map && data['success'] == true) return;
    throw Exception('Failed to deploy story to sprint');
  }
}
