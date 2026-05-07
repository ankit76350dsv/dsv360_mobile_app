class TimerInfoModel {
  final String message;
  final String timerId;
  final String? taskId;
  final String taskName;
  final String entryDate;
  final String startTime;
  final String sourceType;
  final String sprintId;
  final String storyId;
  final String sprintTaskId;
  final String? sprintSubTaskId;

  TimerInfoModel({
    required this.message,
    required this.timerId,
    this.taskId,
    required this.taskName,
    required this.entryDate,
    required this.startTime,
    required this.sourceType,
    required this.sprintId,
    required this.storyId,
    required this.sprintTaskId,
    this.sprintSubTaskId,
  });

  bool get isRunning => message.trim().toLowerCase() == 'timer is running';

  factory TimerInfoModel.fromJson(Map<String, dynamic> json) {
    return TimerInfoModel(
      message: json['message'] as String? ?? '',
      timerId: json['TimerId'] as String? ?? '',
      taskId: json['Task_ID'] as String?,
      taskName: json['Task_Name'] as String? ?? '',
      entryDate: json['Entry_Date'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      sourceType: json['Source_Type'] as String? ?? '',
      sprintId: json['Sprint_ID'] as String? ?? '',
      storyId: json['Story_ID'] as String? ?? '',
      sprintTaskId: json['Sprint_Task_ID'] as String? ?? '',
      sprintSubTaskId: json['Sprint_SubTask_ID'] as String?,
    );
  }
}
