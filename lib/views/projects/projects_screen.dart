import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/auth_service.dart';
import '../../models/project_model.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/project_card.dart';
import 'add_project_dialog.dart';
import 'project_details_dialog.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProjectModel> _projects = [];
  List<ProjectModel> _filteredProjects = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
    _filteredProjects = _projects;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    _projects = [
      ProjectModel(
        id: 'P4201',
        projectName: 'Demo Session',
        status: 'Closed',
        client: 'Wipro',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 12, 31),
        assignedTo: 'Ujjwal Mishra',
        owner: 'Aman Jain',
        description: 'Bla bla blnblab',
        progress: 0,
        attachments: [
          'https://tourism.gov.in/sites/default/files/2019-04/dummy-pdf_2.pdf',
          'feedback.png',
        ],
        tasksCount: 5,
        timeEntriesCount: 12,
        issuesCount: 3,
      ),
      ProjectModel(
        id: 'P1443',
        projectName: 'Abhay\'s Team3',
        status: 'Work In Process',
        client: 'Test',
        startDate: DateTime(2025, 11, 4),
        endDate: DateTime(2025, 11, 27),
        assignedTo: 'John Doe',
        owner: 'Jane Smith',
        description: 'Enterprise application development project',
        progress: 45,
        attachments: ['doc1.pdf', 'doc2.pdf'],
        tasksCount: 8,
        timeEntriesCount: 20,
        issuesCount: 5,
      ),
      ProjectModel(
        id: 'P1440',
        projectName: 'test2',
        status: 'Work In Process',
        client: 'Bala & Co',
        startDate: DateTime(2025, 11, 4),
        endDate: DateTime(2025, 11, 5),
        assignedTo: 'Bob Wilson',
        owner: 'Alice Brown',
        description: 'Testing and quality assurance project',
        progress: 30,
        attachments: [],
        tasksCount: 3,
        timeEntriesCount: 7,
        issuesCount: 2,
      ),
      ProjectModel(
        id: 'P1437',
        projectName: 'Testing Add',
        status: 'Work In Process',
        client: 'Bala & Co',
        startDate: DateTime(2025, 11, 4),
        endDate: DateTime(2025, 11, 12),
        assignedTo: 'Alice Brown',
        owner: 'John Doe',
        description: 'Adding new features and testing',
        progress: 60,
        attachments: ['file.pdf'],
        tasksCount: 10,
        timeEntriesCount: 25,
        issuesCount: 4,
      ),
      ProjectModel(
        id: 'P1001',
        projectName: 'Test Employee',
        status: 'Open',
        client: 'TCS',
        startDate: DateTime(2025, 11, 3),
        endDate: DateTime(2025, 11, 19),
        assignedTo: 'Jane Smith',
        owner: 'Bob Wilson',
        description: 'Employee management system development',
        progress: 15,
        attachments: [],
        tasksCount: 4,
        timeEntriesCount: 15,
        issuesCount: 6,
      ),
    ];
  }

  void _filterProjects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProjects = _projects;
      } else {
        _filteredProjects = _projects.where((project) {
          return project.projectName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              project.id.toLowerCase().contains(query.toLowerCase()) ||
              project.client.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _showAddProjectDialog({ProjectModel? project}) async {
    final result = await Navigator.of(context).push<ProjectModel>(
      MaterialPageRoute(
        builder: (context) => AddProjectDialog(project: project),
      ),
    );

    if (result != null) {
      setState(() {
        if (project == null) {
          // Add new project
          _projects.insert(0, result);
        } else {
          // Update existing project
          final index = _projects.indexWhere((p) => p.id == project.id);
          if (index != -1) {
            _projects[index] = result;
          }
        }
        _filterProjects(_searchController.text);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              project == null
                  ? 'Project added successfully'
                  : 'Project updated successfully',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _deleteProject(ProjectModel project) {
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
              setState(() {
                _projects.removeWhere((p) => p.id == project.id);
                _filterProjects(_searchController.text);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project deleted'),
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

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Search Projects',
                    onChanged: _filterProjects,
                  ),
                ),
              ],
            ),
          ),

          // Mobile-Friendly Card List
          Expanded(
            child: _filteredProjects.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = _filteredProjects[index];
                      final isAdmin = AuthService().isAdmin;
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
