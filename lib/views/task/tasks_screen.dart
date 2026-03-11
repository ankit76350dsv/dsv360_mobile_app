import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/providers/task_provider.dart';
import 'package:dsv360/repositories/task_repository.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/attachment.dart';
import '../time_entry/add_time_entry_dialog.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/generic_card.dart';
import '../attachments/attachment_list_modal.dart';
import 'add_task_dialog.dart';
import 'task_details_dialog.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';

class TasksScreen extends ConsumerStatefulWidget {
  final String? projectId;
  final String? projectName;

  const TasksScreen({super.key, this.projectId, this.projectName});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddTaskDialog({
    Task? task,
    required BuildContext context,
  }) async {
    final customColors = Theme.of(context).custom;
    debugPrint('🔧 DIALOG OPENED - Add/Edit Task dialog opened');
    debugPrint('📝 Editing existing task: ${task != null}');
    debugPrint('📁 Current Screen Project ID: "${widget.projectId}"');

    if ((widget.projectId ?? '').isEmpty) {
      debugPrint(
        '⚠️ WARNING: Project ID is empty! User must select a project in the dialog.',
      );
    }

    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (context) =>
            AddTaskDialog(task: task, projectId: widget.projectId ?? ''),
      ),
    );

    debugPrint('🔙 DIALOG CLOSED - Result received: ${result != null}');
    if (result != null) {
      debugPrint('✅ Task data returned from dialog');
      debugPrint('📝 Task ID: ${result.taskId}');
      debugPrint('📝 Task Name: ${result.taskName}');
      debugPrint('📁 Project ID: "${result.projectId}"');
      debugPrint('⚡ Status: ${result.status}');
      debugPrint('👤 Assigned To: ${result.assignedTo}');

      // Check if this is a new task or edit
      final isNewTask = task == null;

      if (isNewTask && result.projectId.isEmpty) {
        debugPrint('❌ Cannot create task without project ID');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Cannot create task without selecting a project',
              ),
              backgroundColor: customColors.error,
            ),
          );
        }
        return;
      }

      // Call the API to create or update task
      try {
        if (isNewTask) {
          debugPrint('📤 Creating new task via API');

          // Get the current user ID for the provider
          final userId = ref.read(currentUserIdProvider);
          debugPrint('🔑 Current User ID: $userId');

          final tasksRepository = ref.read(
            tasksListRepositoryProvider(userId).notifier,
          );

          // Format dates as strings for API
          final startDateStr =
              result.startDate?.toIso8601String().split('T')[0] ?? '';
          final endDateStr =
              result.endDate?.toIso8601String().split('T')[0] ?? '';

          debugPrint('📅 Start Date String: $startDateStr');
          debugPrint('📅 End Date String: $endDateStr');

          // Get all assignee IDs and names (comma-separated)
          // Note: Backend currently only supports single assignee, but we send all selected
          String? assigneeIds = result.assignedToId.isNotEmpty
              ? result.assignedToId
              : null;
          String? assigneeNames = result.assignedTo.isNotEmpty
              ? result.assignedTo
              : null;
          debugPrint('👥 Assignee IDs: $assigneeIds');
          debugPrint('👥 Assignee Names: $assigneeNames');

          await tasksRepository.createTask(
            taskName: result.taskName,
            projectID: result.projectId,
            projectName: result.projectName,
            assignToId: assigneeIds,
            assignToName: assigneeNames,
            status: result.status,
            description: result.description,
            startDate: startDateStr,
            dueDate: endDateStr,
            attachments:
                result.attachmentsForCreation?.cast<Attachment>() ?? [],
          );

          debugPrint('✅ Task created successfully via API');
        } else {
          debugPrint('📝 Updating existing task via API');

          // Get the current user ID for the provider
          final userId = ref.read(currentUserIdProvider);
          debugPrint('🔑 Current User ID: $userId');

          final tasksRepository = ref.read(
            tasksListRepositoryProvider(userId).notifier,
          );

          // Format dates as strings for API
          final startDateStr =
              result.startDate?.toIso8601String().split('T')[0] ?? '';
          final endDateStr =
              result.endDate?.toIso8601String().split('T')[0] ?? '';

          // Get all assignee IDs and names (comma-separated)
          String? assigneeIds = result.assignedToId.isNotEmpty
              ? result.assignedToId
              : null;
          String? assigneeNames = result.assignedTo.isNotEmpty
              ? result.assignedTo
              : null;
          debugPrint('👥 Assignee IDs: $assigneeIds');
          debugPrint('👥 Assignee Names: $assigneeNames');

          await tasksRepository.updateTask(
            rowId: result.taskId,
            taskName: result.taskName,
            projectID: result.projectId,
            projectName: result.projectName,
            assignToId: assigneeIds,
            assignToName: assigneeNames,
            status: result.status,
            description: result.description,
            startDate: startDateStr,
            dueDate: endDateStr,
          );

          debugPrint('✅ Task updated successfully via API');
        }
      } catch (e) {
        debugPrint('❌ Error saving task: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving task: $e'),
              backgroundColor: customColors.error,
            ),
          );
        }
        return;
      }

      // Refresh the tasks list after add/edit
      final userId = ref.read(currentUserIdProvider);
      debugPrint('🔄 Refreshing tasks for user: $userId');

      if (mounted) {
        ref.refresh(tasksListRepositoryProvider(userId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              task == null
                  ? 'Task added successfully'
                  : 'Task updated successfully',
            ),
            backgroundColor: customColors.primary,
          ),
        );
      }
    } else {
      debugPrint('❌ Dialog closed without result (user cancelled)');
    }
  }

  void _deleteTask(Task task, BuildContext context) {
    final customColors = Theme.of(context).custom;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customColors.surfaceBackground,
        title: Text(
          'Delete Task',
          style: TextStyle(color: customColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${task.taskName}"?',
          style: TextStyle(color: customColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: customColors.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Capture the scaffold messenger before popping dialog
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              
              try {
                // Delete task using repository
                final userId = ref.read(currentUserIdProvider);
                await ref
                    .read(tasksListRepositoryProvider(userId).notifier)
                    .deleteTask(task.taskId);

                // Refresh the tasks list
                if (mounted) {
                  ref.refresh(tasksListRepositoryProvider(userId));
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Task "${task.taskName}" deleted successfully',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: customColors.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Error deleting task: $e',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: customColors.error,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: customColors.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final tasksAsync = ref.watch(tasksListRepositoryProvider(userId));
    final searchQuery = ref.watch(tasksSearchQueryProvider);
    final customColors = Theme.of(context).custom;

    return Scaffold(
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 12),
            child: Column(
              children: [
                // ---------- Top bar ----------
                TopBar(
                  title: widget.projectName != null && widget.projectName!.isNotEmpty
                      ? '${widget.projectName} - Tasks'
                      : 'Tasks',
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
                  },
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: CustomSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(tasksSearchQueryProvider.notifier).state = value;
                    },
                    hintText: 'Search task',
                  ),
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                // Filter by project first if projectId is provided
                final projectFilteredTasks = widget.projectId != null && widget.projectId!.isNotEmpty
                    ? tasks.where((task) => task.projectId == widget.projectId).toList()
                    : tasks;

                // Then filter based on search query
                final filteredTasks = searchQuery.isEmpty
                    ? projectFilteredTasks
                    : projectFilteredTasks.where((task) {
                        return task.taskName.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ) ||
                            task.taskId.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            );
                      }).toList();

                return filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: customColors.textSecondary!.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No tasks yet'
                                  : 'No tasks found',
                              style: TextStyle(
                                color: customColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(
                                tasksListRepositoryProvider(userId).notifier,
                              )
                              .refresh(userId);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            final dateFormat = DateFormat('dd/MM/yy');
                            final dateRange =
                                '${dateFormat.format(task.startDate ?? DateTime.now())} - ${dateFormat.format(task.endDate ?? DateTime.now())}';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GenericCard(
                                id: task.taskId.length > 4
                                    ? 'T${task.taskId.substring(task.taskId.length - 4)}'
                                    : 'T${task.taskId}',
                                name: task.taskName,
                                status: task.status,
                                subtitleIcon: 'person',
                                subtitleText: task.assignedTo,
                                dateRange: dateRange,
                                chips: [
                                  CardChip(
                                    icon: Icons.attach_file,
                                    count: '0',
                                    isActive: false,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => AttachmentListModal(
                                          attachments: [],
                                        ),
                                      );
                                    },
                                  ),
                                  CardChip(
                                    icon: Icons.access_time,
                                    count: '0',
                                    isActive: false,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      Navigator.of(context).push<List>(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddTimeEntryDialog(
                                            taskId: task.taskId,
                                            projectId: task.projectId,
                                            taskName: task.taskName,
                                            projectName: task.projectName ?? 'Project',
                                            currentUser: task.assignedTo,
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
                                onEdit: () => _showAddTaskDialog(
                                  task: task,
                                  context: context,
                                ),
                                onDelete: () => _deleteTask(task, context),
                              ),
                            );
                          },
                        ),
                      );
              },
              loading: () => const Center(child: DsvLoader()),
              error: (err, stack) => Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: customColors.error!.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading tasks',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: customColors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: customColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context: context),
        backgroundColor: customColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
