import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../time_entry/add_time_entry_dialog.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/generic_card.dart';
import '../attachments/attachment_list_modal.dart';
import 'add_task_dialog.dart';
import 'task_details_dialog.dart';
// import '../../screens/add_time_entry_dialog.dart';

class TasksScreen extends StatefulWidget {
  final String? projectId;
  final String? projectName;

  const TasksScreen({super.key, this.projectId, this.projectName});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late List<TaskModel> tasks;
  late List<TaskModel> filteredTasks;
  late TextEditingController _searchController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initializeTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeTasks() {
    tasks = [
      TaskModel(
        id: 'T001',
        taskName: 'Design UI Mockups',
        status: 'In Progress',
        projectId: widget.projectId ?? 'P001',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        assignedTo: 'John Doe',
        owner: 'John Doe',
        description: 'Create detailed UI mockups for the main dashboard',
        progress: 65,
        attachments: ['mockup_v1.figma', 'wireframes.pdf'],
        subTasksCount: 3,
        timeEntriesCount: 8,
      ),
      TaskModel(
        id: 'T002',
        taskName: 'API Integration',
        status: 'Pending',
        projectId: widget.projectId ?? 'P001',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        assignedTo: 'Jane Smith',
        owner: 'Jane Smith',
        description: 'Integrate REST APIs for user authentication',
        progress: 0,
        attachments: ['api_docs.md'],
        subTasksCount: 5,
        timeEntriesCount: 0,
      ),
      TaskModel(
        id: 'T003',
        taskName: 'Database Setup',
        status: 'Completed',
        projectId: widget.projectId ?? 'P001',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 3)),
        assignedTo: 'Mike Johnson',
        owner: 'Mike Johnson',
        description: 'Configure PostgreSQL database and migrations',
        progress: 100,
        attachments: [],
        subTasksCount: 2,
        timeEntriesCount: 12,
      ),
      TaskModel(
        id: 'T004',
        taskName: 'Testing & QA',
        status: 'In Progress',
        projectId: widget.projectId ?? 'P001',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 10)),
        assignedTo: 'Sarah Lee',
        owner: 'Sarah Lee',
        description: 'Perform comprehensive testing across all modules',
        progress: 45,
        attachments: ['test_cases.xlsx', 'bug_report.pdf'],
        subTasksCount: 8,
        timeEntriesCount: 5,
      ),
    ];
    filteredTasks = tasks;
  }

  void _filterTasks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredTasks = tasks;
      } else {
        filteredTasks = tasks
            .where(
              (task) =>
                  task.taskName.toLowerCase().contains(query.toLowerCase()) ||
                  task.id.toLowerCase().contains(query.toLowerCase()) ||
                  task.status.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _showAddTaskDialog({TaskModel? task}) async {
    final result = await Navigator.of(context).push<TaskModel>(
      MaterialPageRoute(
        builder: (context) =>
            AddTaskDialog(task: task, projectId: widget.projectId ?? 'P001'),
      ),
    );

    if (result != null) {
      setState(() {
        if (task == null) {
          // Add new task
          tasks.insert(0, result);
        } else {
          // Update existing task
          final index = tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            tasks[index] = result;
          }
        }
        _filterTasks(_searchController.text);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              task == null
                  ? 'Task added successfully'
                  : 'Task updated successfully',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _deleteTask(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Delete Task',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${task.taskName}"?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                tasks.removeWhere((t) => t.id == task.id);
                _filterTasks(_searchController.text);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task deleted'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 12),
            child: Column(
              children: [
                // ---------- Top bar ----------
                TopBar(
                  title: 'Tasks',
                  onBack: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardPage(),
                        ),
                      );
                    }
                  },
                  onInfoTap: () {
                    // hook for info action
                    // you can open a dialog or screen here
                  },
                ),

                //Padding(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 16,
                //     vertical: 8,
                //   ),
                //   child: CustomSearchBar(
                //     controller: _searchController,
                //     onChanged: _filterTasks,
                //     hintText: 'Search task',
                //   ),
                // ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: _filterTasks,
              hintText: 'Search task',
            ),
          ),

          // Task List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'No tasks yet'
                              : 'No tasks found',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final dateFormat = DateFormat('dd/MM/yy');
                      final dateRange =
                          '${dateFormat.format(task.startDate)} - ${dateFormat.format(task.endDate)}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GenericCard(
                          id: task.id,
                          name: task.taskName,
                          status: task.status,
                          subtitleIcon: 'person',
                          subtitleText: task.assignedTo ?? 'Unassigned',
                          dateRange: dateRange,
                          chips: [
                            CardChip(
                              icon: Icons.attach_file,
                              count: task.attachments.length.toString(),
                              isActive: task.attachments.isNotEmpty,
                              onTap: task.attachments.isNotEmpty
                                  ? () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            AttachmentListModal(
                                              attachments: task.attachments,
                                            ),
                                      );
                                    }
                                  : null,
                            ),
                            CardChip(
                              icon: Icons.access_time,
                              count: task.timeEntriesCount.toString(),
                              isActive: task.timeEntriesCount > 0,
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.of(context).push<List>(
                                  MaterialPageRoute(
                                    builder: (context) => AddTimeEntryDialog(
                                      taskId: task.id,
                                      taskName: task.taskName,
                                      currentUser:
                                          task.assignedTo ?? 'Unassigned',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  TaskDetailsDialog(task: task),
                            );
                          },
                          onEdit: () => _showAddTaskDialog(task: task),
                          onDelete: () => _deleteTask(task),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
