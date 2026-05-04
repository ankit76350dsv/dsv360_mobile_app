import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/connectivity_provider.dart';
import '../../core/widgets/global_error.dart';
import '../../core/widgets/global_loader.dart';
import '../../providers/project_provider.dart';
import '../../providers/employee_provider.dart';
import '../../core/constants/auth_manager.dart';
import '../../models/project_model.dart';
import '../widgets/custom_search_bar.dart';
import 'project_card.dart';
import 'add_project_dialog.dart';
import 'project_details_dialog.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/features/dashboard/view/pages/AppDrawer.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  // We don't need a local _projects list anymore as it comes from the provider.
  // We might keep a query string to trigger rebuilds if we want, or just read controller.
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isAdminUser() {
    final user = AuthManager.instance.currentUser;
    final roleName = user?.role?.name ?? '';
    final isAdminOrManager = roleName == 'Admin' ||
                             roleName == 'Admin (Default)' || 
                             roleName == 'Super Admin' || 
                             roleName == 'App Administrator' ||
                             roleName == 'Manager/Team Lead';
    debugPrint('🔐 Projects Screen - Checking permission: $isAdminOrManager | Role: $roleName');
    return isAdminOrManager;
  }

  List<ProjectModel> _filterProjects(List<ProjectModel> projects) {
    if (_searchQuery.isEmpty) {
      return projects;
    }
    return projects.where((project) {
      return project.projectName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          project.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.client.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _showAddProjectDialog({ProjectModel? project, required BuildContext context}) async {
    final customColors = Theme.of(context).custom;
    final projectRepository = ref.read(projectRepositoryProvider);
    final employeeRepository = ref.read(employeeRepositoryProvider);

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => AddProjectDialog(
          project: project,
          projectRepository: projectRepository,
          employeeRepository: employeeRepository,
        ),
      ),
    );

    // Refresh the list if operation was successful
    if (result != null && result['success'] == true && mounted) {
      ref.invalidate(projectListProvider);
      final action = result['action'] ?? 'saved';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Project ${action == 'create' ? 'created' : 'updated'} successfully',
          ),
          backgroundColor: customColors.avatarBackground,
        ),
      );
    }
  }

  void _deleteProject(ProjectModel project, BuildContext context) {
    final customColors = Theme.of(context).custom;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customColors.cardBackground,
        title: Text(
          'Delete Project',
          style: TextStyle(color: customColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${project.projectName}"?',
          style: TextStyle(color: customColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: customColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Capture the scaffold messenger before popping dialog
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);

              try {
                final projectRepository = ref.read(projectRepositoryProvider);
                await projectRepository.deleteProject(project.id);

                if (mounted) {
                  ref.invalidate(projectListProvider);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Project "${project.projectName}" deleted successfully',
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
                              'Failed to delete project: ${e.toString()}',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final connectivityStatus = ref.watch(checkConnectivityProvider);

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
                        title: 'Projects',
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
                      ),
                    ),
                    Expanded(
                      child: GlobalError(
                        message: 'Please check your internet connection.',
                        isNetworkError: true,
                        onRetry: () {
                          ref.invalidate(checkConnectivityProvider);
                        },
                      ),
                    ),
                  ],
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  return await ref.refresh(projectListProvider.future);
                },
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.only(top: 48, bottom: 12),
                      child: Column(
                        children: [
                          // ---------- Top bar ----------
                          TopBar(
                            title: 'Projects',
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CustomSearchBar(
                              controller: _searchController,
                              hintText: 'Search Projects',
                              onChanged: (val) {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mobile-Friendly Card List
                    Expanded(
                      child: ref
                          .watch(projectListProvider)
                          .when(
                            loading: () => const Center(
                              child: GlobalLoader(
                                message: 'Loading projects...',
                              ),
                            ),
                            error: (err, stack) => GlobalError(
                              message: 'Failed to load projects. Please try again.',
                              onRetry: () => ref.refresh(projectListProvider),
                            ),
                            data: (projects) {
                              final filteredProjects = _filterProjects(
                                projects,
                              );

                              if (filteredProjects.isEmpty) {
                                // Add Stack to allow refresh even when list is empty
                                return Stack(
                                  children: [
                                    ListView(), // Empty list for Pull-to-Refresh
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.folder_open,
                                            size: 80,
                                            color: customColors.textSecondary!
                                                .withValues(alpha: 0.3),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No projects found',
                                            style: TextStyle(
                                              color: customColors.textSecondary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredProjects.length,
                                itemBuilder: (context, index) {
                                  final project = filteredProjects[index];
                                  final user = AuthManager.instance.currentUser;
                                  final roleName = user?.role?.name ?? '';
                                  final isAdminOrManager = roleName == 'Admin' ||
                                                           roleName == 'Admin (Default)' || 
                                                           roleName == 'Super Admin' || 
                                                           roleName == 'App Administrator' ||
                                                           roleName == 'Manager/Team Lead';
                                  debugPrint('👤 ProjectCard Permission Check - Role: "$roleName" | isAdminOrManager: $isAdminOrManager | User: ${user?.firstName}');
                                  return ProjectCard(
                                    project: project,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            ProjectDetailsDialog(
                                              project: project,
                                            ),
                                      );
                                    },
                                    onEdit: isAdminOrManager
                                        ? () => _showAddProjectDialog(project: project, context: context)
                                        : null,
                                    onDelete: isAdminOrManager
                                        ? () => _deleteProject(project, context)
                                        : null,
                                  );
                                },
                              );
                            },
                          ),
                    ),
                  ],
                ),
              );
            },
            error: (error, stack) => GlobalError(
              message: 'Something went wrong. Please check your connection.',
              isNetworkError: true,
              onRetry: () => ref.invalidate(checkConnectivityProvider),
            ),
            loading: () =>
                const GlobalLoader(message: 'Checking connection...'),
          );
        },
      ),
      floatingActionButton: connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) return null;
          if (ref.watch(projectListProvider).hasError) return null;
          if (!_isAdminUser()) return null;
          return FloatingActionButton(
            onPressed: () => _showAddProjectDialog(context: context),
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
