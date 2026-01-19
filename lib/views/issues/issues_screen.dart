import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/issue_model.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/generic_card.dart';
import '../widgets/TopBar.dart';
import '../attachments/attachment_list_modal.dart';
import 'assignee_modal.dart';
import 'add_issue_form_screen.dart';
import 'issue_details_modal_sheet.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<IssueModel> _issues = [];
  List<IssueModel> _filteredIssues = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
    _filteredIssues = _issues;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    _issues = [
      IssueModel(
        id: 'I001',
        issueName: 'Login page not responsive',
        status: 'Open',
        priority: 'High',
        description: 'The login page breaks on mobile devices',
        assignedTo: 'John Doe',
        owner: 'Alice Smith',
        createdDate: DateTime(2026, 1, 5),
        dueDate: DateTime(2026, 1, 15),
        projectId: 'P4201',
        projectName: 'Demo Session',
        attachments: ['screenshot.png'],
        commentsCount: 3,
      ),
      IssueModel(
        id: 'I002',
        issueName: 'Database connection timeout',
        status: 'In Progress',
        priority: 'Critical',
        description: 'Database queries are timing out under load',
        assignedTo: 'Jane Smith',
        owner: 'Bob Johnson',
        createdDate: DateTime(2026, 1, 3),
        dueDate: DateTime(2026, 1, 12),
        projectId: 'P4201',
        projectName: 'Demo Session',
        attachments: ['error_log.txt', 'query_trace.pdf'],
        commentsCount: 5,
      ),
      IssueModel(
        id: 'I003',
        issueName: 'Improve search performance',
        status: 'Open',
        priority: 'Medium',
        description: 'Search functionality needs optimization',
        assignedTo: 'Mike Johnson',
        owner: 'Charlie Brown',
        createdDate: DateTime(2026, 1, 1),
        dueDate: DateTime(2026, 1, 20),
        projectId: 'P4201',
        projectName: 'Demo Session',
        attachments: [],
        commentsCount: 2,
      ),
      IssueModel(
        id: 'I004',
        issueName: 'Fix typo in documentation',
        status: 'Closed',
        priority: 'Low',
        description: 'Minor spelling error in API docs',
        assignedTo: 'Sarah Lee',
        owner: 'David Wilson',
        createdDate: DateTime(2025, 12, 28),
        dueDate: DateTime(2026, 1, 8),
        projectId: 'P4201',
        projectName: 'Demo Session',
        attachments: [],
        commentsCount: 1,
      ),
    ];
    _filteredIssues = _issues;
  }

  void _filterIssues(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredIssues = _issues;
      } else {
        _filteredIssues = _issues
            .where((issue) =>
                issue.issueName.toLowerCase().contains(query.toLowerCase()) ||
                issue.id.toLowerCase().contains(query.toLowerCase()) ||
                issue.status.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Color _getPriorityColor(String priority) {
  //   switch (priority) {
  //     case 'Critical':
  //       return AppColors.error;
  //     case 'High':
  //       return AppColors.statusInProgress;
  //     case 'Medium':
  //       return AppColors.primary;
  //     case 'Low':
  //       return AppColors.statusCompleted;
  //     default:
  //       return AppColors.textSecondary;
  //   }
  // }

  Future<void> _showAddIssueDialog({IssueModel? issue}) async {
    final result = await Navigator.of(context).push<IssueModel>(
      MaterialPageRoute(
        builder: (context) => AddIssueFormScreen(
          issue: issue,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (issue == null) {
          // Add new issue
          _issues.insert(0, result);
        } else {
          // Update existing issue
          final index = _issues.indexWhere((i) => i.id == issue.id);
          if (index != -1) {
            _issues[index] = result;
          }
        }
        _filterIssues(_searchController.text);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              issue == null ? 'Issue added successfully' : 'Issue updated successfully',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _deleteIssue(IssueModel issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Delete Issue',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${issue.issueName}"?',
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
                _issues.removeWhere((i) => i.id == issue.id);
                _filterIssues(_searchController.text);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issue deleted'),
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
                  title: 'Issues',
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
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: _filterIssues,
              hintText: 'Search issues',
            ),
          ),

          // Issues List
          Expanded(
            child: _filteredIssues.isEmpty
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
                          _searchController.text.isEmpty ? 'No issues yet' : 'No issues found',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredIssues.length,
                    itemBuilder: (context, index) {
                      final issue = _filteredIssues[index];
                      final dateFormat = DateFormat('dd/MM/yy');
                      final createdDate = dateFormat.format(issue.createdDate);
                      final dueDate = issue.dueDate != null ? dateFormat.format(issue.dueDate!) : 'N/A';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GenericCard(
                          id: issue.id,
                          name: issue.issueName,
                          status: issue.status,
                          subtitleIcon: 'business',
                          subtitleText: issue.projectName ?? 'N/A',
                          dateRange: 'Created: $createdDate',
                          dueDate: 'Due: $dueDate',
                          chips: [
                            CardChip(
                              icon: Icons.person_outline,
                              count: '1',
                              isActive: true,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => AssigneeModal(
                                    assignedTo: issue.assignedTo ?? 'Unassigned',
                                    owner: issue.owner ?? 'N/A',
                                  ),
                                );
                              },
                            ),
                            CardChip(
                              icon: Icons.attach_file,
                              count: issue.attachments.length.toString(),
                              isActive: issue.attachments.isNotEmpty,
                              onTap: issue.attachments.isNotEmpty
                                  ? () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            AttachmentListModal(
                                              attachments: issue.attachments,
                                            ),
                                      );
                                    }
                                  : null,
                            ),
                          ],
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => IssueDetailsModalSheet(issue: issue),
                            );
                          },
                          onEdit: () => _showAddIssueDialog(issue: issue),
                          onDelete: () => _deleteIssue(issue),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIssueDialog(),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
