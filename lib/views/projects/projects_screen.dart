import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/auth_manager.dart';
import '../../models/project_model.dart';
import '../widgets/custom_search_bar.dart';
import 'project_card.dart';
import 'add_project_dialog.dart';
import 'project_details_dialog.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';

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

  Future<void> _showAddProjectDialog({ProjectModel? project}) async {
    // Note: Creating/Updating not fully implemented with backend yet, still using local sample logic or need to update
    // For now we just show dialog. If we want to support invalidating provider, we need to do that here.
    
    await Navigator.of(context).push<ProjectModel>(
      MaterialPageRoute(
        builder: (context) => AddProjectDialog(project: project),
      ),
    );
    
    // Refresh the list after add/edit
    ref.refresh(projectListProvider);
  }

  void _deleteProject(ProjectModel project) {
    // Note: Delete not implemented in backend yet.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${project.projectName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete API call
              // ref.read(projectRepositoryProvider).deleteProject(project.id);
              // ref.refresh(projectListProvider);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete not implemented yet'),
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
      drawer: const AppDrawer(),
      body: Column(
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
                        MaterialPageRoute(builder: (_) => const DashboardPage()),
                      );
                    }
                  },
                  onInfoTap: () {
                    // hook for info action
                    // you can open a dialog or screen here
                  },
                ),

               // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Search Projects',
                    // onChanged is handled by listener now
                    onChanged: (val) {}, 
                  ),
                ),
              ],
            ),
          ),

          // Mobile-Friendly Card List
          Expanded(
            child: ref.watch(projectListProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (projects) {
                final filteredProjects = _filterProjects(projects);
                
                if (filteredProjects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No projects found',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    final user = AuthManager.instance.currentUser;
                    final isAdmin = user?.role?.name == 'Admin';
                    return ProjectCard(
                      project: project,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              ProjectDetailsDialog(project: project),
                        );
                      },
                      onEdit: isAdmin
                          ? () => _showAddProjectDialog(project: project)
                          : null,
                      onDelete: isAdmin
                          ? () => _deleteProject(project)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
