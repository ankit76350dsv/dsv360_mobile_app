import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/widgets/global_error.dart';
import '../../../../core/widgets/global_loader.dart';
import '../../viewmodel/project_viewmodel.dart';
import '../../../users/viewmodel/employee_viewmodel.dart';
import '../../../../core/constants/auth_manager.dart';
import '../../model/project_model.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../widgets/project_card.dart';
import 'add_project_dialog.dart';
import '../widgets/project_details_dialog.dart';
import 'package:dsv360/core/widgets/TopBar.dart';
import 'package:dsv360/features/dashboard/view/widgets/AppDrawer.dart';
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
  bool _isRefreshingData = false;

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
      
      showSuccessSnackBar(context, 'Project ${action == 'create' ? 'created' : 'updated'} successfully');
    }
  }

  void _deleteProject(ProjectModel project, BuildContext context) {
   

    showWarningDialogueBox(
      context: context,
      title: 'Delete Project',
      subtitle: 'Are you sure you want to delete "${project.projectName}"?',
      primaryText: 'Delete',
      onPrimaryPressed: (dialogContext) async {
        Navigator.of(dialogContext).pop();

        try {
          final projectRepository = ref.read(projectRepositoryProvider);
          await projectRepository.deleteProject(project.id);

          if (mounted) {
            ref.invalidate(projectListProvider);
            showSuccessSnackBar(context, 'Project "${project.projectName}" deleted successfully');
          }
        } catch (e) {
          if (mounted) {
            
            showErrorSnackBar(context, 'Failed to delete Project. Try again later.');
          }
        }
      },
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
                return SafeArea(
                  child: Column(
                    children: [
                      
                        
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
                          onInfoTap: () async {
                            if (_isRefreshingData) return;
                            setState(() => _isRefreshingData = true);
                            try {
                              final _ = await ref.refresh(projectListProvider.future);
                              if (mounted) {
                                showSuccessSnackBar(context, 'Projects refreshed successfully');
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
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  return await ref.refresh(projectListProvider.future);
                },
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header Section
                      
                        
                       Column(
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
                              onInfoTap: () async {
                                if (_isRefreshingData) return;
                                setState(() => _isRefreshingData = true);
                                try {
                                  final _ = await ref.refresh(projectListProvider.future);
                                  if (mounted) {
                                    showSuccessSnackBar(context, 'Projects refreshed successfully');
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
                                  itemCount: filteredProjects.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == filteredProjects.length) {
                                      return const SizedBox(height: 60);
                                    }

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
