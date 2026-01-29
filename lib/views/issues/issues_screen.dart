import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/issue_model.dart';
import '../../providers/issue_provider.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/generic_card.dart';
import '../widgets/TopBar.dart';
import '../attachments/attachment_list_modal.dart';
import 'assignee_modal.dart';
import 'add_issue_form_screen.dart';
import 'issue_details_modal_sheet.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';

class IssuesScreen extends ConsumerStatefulWidget {
  const IssuesScreen({super.key});

  @override
  ConsumerState<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends ConsumerState<IssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
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

  List<IssueModel> _filterIssues(List<IssueModel> issues) {
    if (_searchQuery.isEmpty) {
      return issues;
    }
    return issues.where((issue) {
      return issue.issueName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          issue.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          issue.status.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _showAddIssueDialog({IssueModel? issue}) async {
    final issueRepository = ref.read(issueRepositoryProvider);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddIssueFormScreen(
          issue: issue,
          issueRepository: issueRepository,
        ),
      ),
    );

    if (result == true && mounted) {
      ref.refresh(issueListProvider);
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

  Future<void> _deleteIssue(IssueModel issue) async {
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                final repository = ref.read(issueRepositoryProvider);
                await repository.deleteIssue(issue.id);
                ref.refresh(issueListProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Issue deleted successfully'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete issue: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
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
                        MaterialPageRoute(builder: (_) => const DashboardPage()),
                      );
                    }
                  },
                  onInfoTap: () {
                    // hook for info action
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Search Issues',
                    onChanged: (_) {}, // Trigger rebuild via _searchQuery
                  ),
                ),
              ],
            ),
          ),

          // Issues List
          Expanded(
            child: ref.watch(issueListProvider).when(
              data: (issues) {
                final filteredIssues = _filterIssues(issues);
                
                if (filteredIssues.isEmpty) {
                  return Center(
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
                          _searchQuery.isEmpty ? 'No issues yet' : 'No issues found',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredIssues.length,
                    itemBuilder: (context, index) {
                      final issue = filteredIssues[index];
                      final dateFormat = DateFormat('dd/MM/yy');
                      final createdDate = dateFormat.format(issue.createdDate);
                      final dueDate = issue.dueDate != null ? dateFormat.format(issue.dueDate!) : 'N/A';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GenericCard(
                          id: issue.id.length > 4 
                              ? 'I${issue.id.substring(issue.id.length - 4)}' 
                              : 'I${issue.id}',
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
                  );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading issues',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(issueListProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
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
