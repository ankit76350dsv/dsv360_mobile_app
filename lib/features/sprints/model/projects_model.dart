class ProjectModel {
  final String rowId;
  final String projectName;
  final String clientName;
  final String status;
  final String owner;
  final String ownerId;
  final String assignedTo;
  final String assignedToId;
  final String startDate;
  final String endDate;
  final String createdTime;
  final String modifiedTime;
  final String description;
  final String files;
  final String clientId;
  final String? creatorId;

  ProjectModel({
    required this.rowId,
    required this.projectName,
    required this.clientName,
    required this.status,
    required this.owner,
    required this.ownerId,
    required this.assignedTo,
    required this.assignedToId,
    required this.startDate,
    required this.endDate,
    required this.createdTime,
    required this.modifiedTime,
    required this.description,
    required this.files,
    required this.clientId,
    this.creatorId,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      rowId: json['ROWID'] ?? '',
      projectName: json['Project_Name'] ?? '',
      clientName: json['Client_Name'] ?? '',
      status: json['Status'] ?? '',
      owner: json['Owner'] ?? '',
      ownerId: json['Owner_Id'] ?? '',
      assignedTo: json['Assigned_To'] ?? '',
      assignedToId: json['Assigned_To_Id'] ?? '',
      startDate: json['Start_Date'] ?? '',
      endDate: json['End_Date'] ?? '',
      createdTime: json['CREATEDTIME'] ?? '',
      modifiedTime: json['MODIFIEDTIME'] ?? '',
      description: json['Description'] ?? '',
      files: json['Files'] ?? '',
      clientId: json['Client_ID'] ?? '',
      creatorId: json['CREATORID'],
    );
  }
}