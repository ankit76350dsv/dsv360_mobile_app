import 'package:dsv360/features/sprints/model/epic_model.dart';
import 'package:dsv360/features/sprints/model/release_milestone_model.dart';
import 'package:dsv360/features/sprints/model/story_model.dart';
import 'package:dsv360/features/sprints/model/sub_task_model.dart';
import 'package:dsv360/features/sprints/model/task_model.dart';

class HierarchyModel {
  final List<ReleaseMilestoneModel> milestones;
  final List<EpicModel> epics;
  final List<StoryModel> stories;
  final List<TaskModel> tasks;
  final List<SubTaskModel> subtasks;

  HierarchyModel({
    required this.milestones,
    required this.epics,
    required this.stories,
    required this.tasks,
    required this.subtasks,
  });

  factory HierarchyModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return HierarchyModel(
      milestones: (data['milestones'] as List? ?? [])
          .map((e) => ReleaseMilestoneModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      epics: (data['epics'] as List? ?? [])
          .map((e) => EpicModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      stories: (data['stories'] as List? ?? [])
          .map((e) => StoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      tasks: (data['tasks'] as List? ?? [])
          .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      subtasks: (data['subTasks'] as List? ?? []).map((e)=>SubTaskModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}