class DashboardModel {
  final bool success;
  final int userCnt;
  final int taskCnt;
  final YearTaskData yearTaskData;
  final int projectCnt;
  final int completedProjectCnt;
  final List<YearMonthProjectData> yearMonthwiseUserProjects;
  final int issueCnt;

  DashboardModel({
    required this.success,
    required this.userCnt,
    required this.taskCnt,
    required this.yearTaskData,
    required this.projectCnt,
    required this.completedProjectCnt,
    required this.yearMonthwiseUserProjects,
    required this.issueCnt,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      success: json['success'] ?? false,
      userCnt: json['userCnt'] ?? 0,
      taskCnt: json['taskCnt'] ?? 0,
      yearTaskData: YearTaskData.fromJson(json['yearTaskData'] ?? {}),
      projectCnt: json['projectCnt'] ?? 0,
      completedProjectCnt: json['completedProjectCnt'] ?? 0,
      yearMonthwiseUserProjects: (json['yearMonthwiseUserProjects'] as List<dynamic>?)
              ?.map((e) => YearMonthProjectData.fromJson(e))
              .toList() ??
          [],
      issueCnt: json['issueCnt'] ?? 0,
    );
  }
}

class YearTaskData {
  final int open;
  final int inProgress;
  final int closed;

  YearTaskData({
    required this.open,
    required this.inProgress,
    required this.closed,
  });

  factory YearTaskData.fromJson(Map<String, dynamic> json) {
    return YearTaskData(
      open: json['open'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      closed: json['closed'] ?? 0,
    );
  }
}

class YearMonthProjectData {
  final int open;
  final int inProgress;
  final int closed;

  YearMonthProjectData({
    required this.open,
    required this.inProgress,
    required this.closed,
  });

  factory YearMonthProjectData.fromJson(Map<String, dynamic> json) {
    return YearMonthProjectData(
      open: json['open'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      closed: json['closed'] ?? 0,
    );
  }
}
