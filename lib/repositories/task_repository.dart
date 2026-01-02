import 'package:dsv360/models/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class TasksRepository extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return fetchProjects();
  }

  Future<List<Task>> fetchProjects() async {
    // TODO: replace with Dio call
    await Future.delayed(const Duration(seconds: 2));

    return [
      Task(
        taskName: "Abhay Singh Patel",
        description: "jhv",
        status: "Open",
        projectName: "testing",
        assignedTo: "adsadas Patel",
        startDate: DateTime.parse("2025-11-03"),
        endDate: DateTime.parse("2025-11-30"),
      ),
    ];
  }
}


final taskRepositoryProvider =
    FutureProvider<List<Task>>((ref) async {
  // ⏳ Simulate network delay
  await Future.delayed(const Duration(seconds: 2));

    // ❌ Uncomment to test error state
    // throw Exception("Failed to load tasks");

    return <Task>[
      Task(
        taskName: "Abhay Singh Patel",
        description: "jhv",
        status: "Open",
        projectName: "testing",
        assignedTo: "adsadas Patel",
        startDate: DateTime.parse("2025-11-03"),
        endDate: DateTime.parse("2025-11-30"),
      ),
      Task(
        taskName: "UI Improvements",
        description: "Improve dashboard UI",
        status: "In Progress",
        projectName: "Mobile App",
        assignedTo: "Aman Jain",
        startDate: DateTime.parse("2025-10-15"),
        endDate: DateTime.parse("2025-12-01"),
      ),
    ];
  }
);

// final tasksRepositoryProvider =
//     AsyncNotifierProvider<TasksRepository, List<Task>>(
//   TasksRepository.new,
// );
