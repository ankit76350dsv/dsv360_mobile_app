import 'dart:convert';

class RequestEntryModel{
  final String? approveByID;
  final String? approveDate;
  final String? approvedBy;
  final String projectId;
  final String projectName;
  final String? reason;
  final bool rejected;
  final String status;
  final String taskId;
  final String taskName;
  final String timeEntryData; // JSON-encoded array string
  final String userId;
  final String username;

  RequestEntryModel({
    this.approveByID,
    this.approveDate,
    this.approvedBy,
    required this.projectId,
    required this.projectName,
    this.reason,
    required this.rejected,
    required this.status,
    required this.taskId,
    required this.taskName,
    required this.timeEntryData,
    required this.userId,
    required this.username,
  });

  // Factory to create from JSON
  factory RequestEntryModel.fromJson(Map<String, dynamic> json) {
    return RequestEntryModel(
      approveByID: json['ApproveByID'],
      approveDate: json['ApproveDate'],
      approvedBy: json['ApprovedBy'],
      projectId: json['Project_ID'],
      projectName: json['Project_Name'],
      reason: json['Reason'],
      rejected: json['Rejected'] == true || json['Rejected'] == 'true',
      status: json['Status'],
      taskId: json['Task_Id'],
      taskName: json['Task_Name'],
      timeEntryData: json['Timeentry_Data'],
      userId: json['User_Id'],
      username: json['Username'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ApproveByID': approveByID,
      'ApproveDate': approveDate,
      'ApprovedBy': approvedBy,
      'Project_ID': projectId,
      'Project_Name': projectName,
      'Reason': reason,
      'Rejected': rejected,
      'Status': status,
      'Task_Id': taskId,
      'Task_Name': taskName,
      'Timeentry_Data': timeEntryData,
      'User_Id': userId,
      'Username': username,
    };
  }

  // Helper to encode a list of time entry maps to JSON string
  static String encodeTimeEntryList(List<Map<String, dynamic>> entries) {
    return jsonEncode(entries);
  }

  // Helper to decode the JSON string to a list of maps
  static List<Map<String, dynamic>> decodeTimeEntryList(String data) {
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }
}