import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/time_entry/repositories/check_timer_status_repository.dart';
import 'package:dsv360/features/time_entry/view/pages/timer_service.dart';
import 'package:dsv360/features/task/providers/task_provider.dart';
import 'package:dsv360/features/task/repositories/fetch_tasks_repository.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/core/widgets/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/task.dart';
import '../../../../core/models/attachment.dart';
import '../../../time_entry/view/pages/add_time_entry_dialog.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/generic_card.dart';
import '../../../../core/models/attachment_list_modal.dart';
import 'add_task_dialog.dart';
import 'task_details_dialog.dart';
import 'package:dsv360/features/dashboard/view/widgets/AppDrawer.dart';

class TasksScreen extends ConsumerStatefulWidget {
  final String? projectId;
  final String? projectName;

  const TasksScreen({super.key, this.projectId, this.projectName});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  late TextEditingController _searchController;
  // taskId of the task that currently has a running timer (null = no timer running)
  String? _runningTaskId;
  bool _isRefreshingData = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchTimerStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  Future<void> _fetchTimerStatus() async {
    final userId = ref.read(currentUserIdProvider);
    try {
      final status = await CheckTimerStatusRepository().checkTimerStatus(userId);
      debugPrint('⏱️ Timer status response: $status');

      final message = (status['message'] ?? '').toString().toLowerCase();
      final isRunning = message.contains('running') && !message.contains('not');

      if (isRunning) {
        final taskId = (status['Task_ID'] ?? '').toString();
        // startTime from server: "2026-04-01 17:20:32"
        final startTimeStr = (status['startTime'] ?? '').toString();
        final serverStart = DateTime.tryParse(startTimeStr.replaceFirst(' ', 'T'));
        debugPrint('⏱️ Running taskId=$taskId  serverStart=$serverStart');
        if (serverStart != null) {
          TimerService.instance.restoreFromServer(serverStart);
        }
        if (mounted) setState(() => _runningTaskId = taskId);
      } else {
        if (TimerService.instance.isRunning) TimerService.instance.stop();
        if (mounted) setState(() => _runningTaskId = null);
      }
    } catch (e) {
      debugPrint('❌ Error fetching timer status: $e');
      if (TimerService.instance.isRunning) TimerService.instance.stop();
      if (mounted) setState(() => _runningTaskId = null);
    }
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
              content: const Text('Failed to add task. Please try again.'),
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
        ref.invalidate(tasksListRepositoryProvider(userId));
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

    showWarningDialogueBox(
      context: context,
      title: 'Delete Task',
      subtitle: 'Are you sure you want to delete "${task.taskName}"? This action cannot be undone.',
      primaryText: 'Delete',
      onPrimaryPressed: (dialogContext) async {
        Navigator.pop(dialogContext);
        
        try {
          // Delete task using repository
          final userId = ref.read(currentUserIdProvider);
          await ref
              .read(tasksListRepositoryProvider(userId).notifier)
              .deleteTask(task.taskId);

          // Refresh the tasks list
          if (mounted) {
            ref.invalidate(tasksListRepositoryProvider(userId));
            ScaffoldMessenger.of(context).showSnackBar(
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
            ScaffoldMessenger.of(context).showSnackBar(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final tasksAsync = ref.watch(tasksListRepositoryProvider(userId));
    final searchQuery = ref.watch(tasksSearchQueryProvider);
    final customColors = Theme.of(context).custom;
    final connectivityStatus = ref.watch(checkConnectivityProvider);

    final title = widget.projectName != null && widget.projectName!.isNotEmpty
        ? '${widget.projectName} - Tasks'
        : 'Tasks';

    void onBack() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    }

    return Scaffold(
      backgroundColor: customColors.background,
      drawer: const AppDrawer(),
      body: Builder(
        builder: (context) {
          return connectivityStatus.when(
            data: (results) {
              if (results.contains(ConnectivityResult.none)) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 48, bottom: 12),
                      child: TopBar(
                        title: title,
                        onBack: onBack,
                        onInfoTap: () async {
                          if (_isRefreshingData) return;
                          setState(() => _isRefreshingData = true);
                          try {
                            final _ = await ref.refresh(
                              tasksListRepositoryProvider(userId).future,
                            );
                            if (mounted) {
                              showSuccessSnackBar(context, 'Tasks refreshed successfully');
                            }
                          } catch (e) {
                            debugPrint('Refresh error: $e');
                            if (mounted) {
                              showErrorSnackBar(context, 'Refresh failed. Please try again.');
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isRefreshingData = false);
                            }
                          }
                        },
                        actionIcon: Icons.refresh_rounded,
                      ),
                    ),
                    Expanded(
                      child: GlobalError(
                        message: 'Please check your internet connection.',
                        isNetworkError: true,
                        onRetry: () {
                          ref.invalidate(checkConnectivityProvider);
                          ref.invalidate(tasksListRepositoryProvider(userId));
                          _fetchTimerStatus();
                        },
                      ),
                    ),
                  ],
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(tasksListRepositoryProvider(userId).notifier)
                      .refresh(userId);
                  await _fetchTimerStatus();
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 48, bottom: 12),
                      child: Column(
                        children: [
                          TopBar(
                            title: title,
                            onBack: onBack,
                            onInfoTap: () async {
                              if (_isRefreshingData) return;
                              setState(() => _isRefreshingData = true);
                              try {
                                final _ = await ref.refresh(
                                  tasksListRepositoryProvider(userId).future,
                                );
                                if (mounted) {
                                  showSuccessSnackBar(context, 'Tasks refreshed successfully');
                                }
                              } catch (e) {
                                debugPrint('Refresh error: $e');
                                if (mounted) {
                                  showErrorSnackBar(context, 'Refresh failed. Please try again.');
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isRefreshingData = false);
                                }
                              }
                            },
                            actionIcon: Icons.refresh_rounded,
                          ),
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
                    Expanded(
                      child: tasksAsync.when(
                        skipLoadingOnRefresh: true,
                        data: (tasks) {
                          final projectFilteredTasks = widget.projectId != null && widget.projectId!.isNotEmpty
                              ? tasks.where((task) => task.projectId == widget.projectId).toList()
                              : tasks;

                          final filteredTasks = searchQuery.isEmpty
                              ? projectFilteredTasks
                              : projectFilteredTasks.where((task) {
                                  return task.taskName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                                      task.taskId.toLowerCase().contains(searchQuery.toLowerCase());
                                }).toList();

                          if (filteredTasks.isEmpty) {
                            return Stack(
                              children: [
                                ListView(),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 64,
                                        color: customColors.textSecondary!.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        searchQuery.isEmpty ? 'No tasks yet' : 'No tasks found',
                                        style: TextStyle(
                                          color: customColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  isTimerRunning: _runningTaskId != null && _runningTaskId == task.taskId,
                                  subtitleIcon: 'person',
                                  subtitleText: task.assignedTo,
                                  dateRange: dateRange,
                                  chips: [
                                    CardChip(
                                      icon: Icons.attach_file,
                                      count: task.attachments.length.toString(),
                                      isActive: task.attachments.isNotEmpty,
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => AttachmentListModal(
                                            attachments: task.attachments,
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
                                            builder: (context) => AddTimeEntryDialog(
                                              taskId: task.taskId,
                                              projectId: task.projectId,
                                              taskName: task.taskName,
                                              projectName: task.projectName,
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
                                      builder: (context) => TaskDetailsDialog(task: task),
                                    );
                                  },
                                  onEdit: () => _showAddTaskDialog(task: task, context: context),
                                  onDelete: () => _deleteTask(task, context),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: DsvLoader()),
                        error: (err, stack) => GlobalError(
                          message: 'Failed to load tasks. Please try again.',
                          onRetry: () {
                            ref.invalidate(tasksListRepositoryProvider(userId));
                            _fetchTimerStatus();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (error, stack) => GlobalError(
              message: 'Something went wrong. Please check your connection.',
              isNetworkError: true,
              onRetry: () {
                ref.invalidate(checkConnectivityProvider);
                ref.invalidate(tasksListRepositoryProvider(userId));
                _fetchTimerStatus();
              },
            ),
            loading: () => const GlobalLoader(message: 'Checking connection...'),
          );
        },
      ),
      floatingActionButton: connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) return null;
          if (tasksAsync.hasError) return null;
          return FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context: context),
            backgroundColor: customColors.primary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
