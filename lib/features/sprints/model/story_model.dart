class StoryModel {
  final String id;

  final String title;
  final String description;

  final String epicId;
  final String sprintId;
  final String projectId;

  final String assigneeId;
  final String primaryOwnership;
  final String secondaryOwnership;

  final String status;
  final int points;
  final String priority;

  final String billingType;
  final String requirementType;

  final String moduleName;
  final String groupName;
  final String zohoProductName;

  final String fiRemarks;
  final String clientRemarks;

  StoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.epicId,
    required this.sprintId,
    required this.projectId,
    required this.assigneeId,
    required this.primaryOwnership,
    required this.secondaryOwnership,
    required this.status,
    required this.points,
    required this.priority,
    required this.billingType,
    required this.requirementType,
    required this.moduleName,
    required this.groupName,
    required this.zohoProductName,
    required this.fiRemarks,
    required this.clientRemarks,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['ROWID']?.toString() ?? '',

      title: json['Title']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',

      epicId: json['EpicID']?.toString() ?? '',
      sprintId: json['SprintID']?.toString() ?? '',
      projectId: json['ProjectID']?.toString() ?? '',

      assigneeId: json['AssigneeID']?.toString() ?? '',
      primaryOwnership: json['PrimaryOwnership']?.toString() ?? '',
      secondaryOwnership: json['SecondaryOwnership']?.toString() ?? '',

      status: json['Status']?.toString() ?? '',
      points: int.tryParse(json['Points']?.toString() ?? '0') ?? 0,
      priority: json['Priority']?.toString() ?? '',

      billingType: json['BillingType']?.toString() ?? '',
      requirementType: json['RequirementType']?.toString() ?? '',

      moduleName: json['ModuleName']?.toString() ?? '',
      groupName: json['GroupName']?.toString() ?? '',
      zohoProductName: json['ZohoProductName']?.toString() ?? '',

      fiRemarks: json['FIRemarks']?.toString() ?? '',
      clientRemarks: json['ClientRemarks']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Title": title,
      "Description": description,
      "EpicID": epicId,
      "SprintID": sprintId,
      "ProjectID": projectId,

      "AssigneeID": assigneeId,
      "PrimaryOwnership": primaryOwnership,
      "SecondaryOwnership": secondaryOwnership,

      "Status": status,
      "Points": points,
      "Priority": priority,

      "BillingType": billingType,
      "RequirementType": requirementType,

      "ModuleName": moduleName,
      "GroupName": groupName,
      "ZohoProductName": zohoProductName,

      "FIRemarks": fiRemarks,
      "ClientRemarks": clientRemarks,
    };
  }

  StoryModel copyWith({
    String? id,
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
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      epicId: epicId ?? this.epicId,
      sprintId: sprintId ?? this.sprintId,
      projectId: projectId ?? this.projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      primaryOwnership: primaryOwnership ?? this.primaryOwnership,
      secondaryOwnership: secondaryOwnership ?? this.secondaryOwnership,
      status: status ?? this.status,
      points: points ?? this.points,
      priority: priority ?? this.priority,
      billingType: billingType ?? this.billingType,
      requirementType: requirementType ?? this.requirementType,
      moduleName: moduleName ?? this.moduleName,
      groupName: groupName ?? this.groupName,
      zohoProductName: zohoProductName ?? this.zohoProductName,
      fiRemarks: fiRemarks ?? this.fiRemarks,
      clientRemarks: clientRemarks ?? this.clientRemarks,
    );
  }
}