import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/issue_model.dart';
import '../../../../providers/issue_provider.dart';
import '../../../../views/widgets/custom_search_bar.dart';
import '../../../../views/widgets/generic_card.dart';
import '../../../../views/widgets/TopBar.dart';
import '../../../../views/attachments/attachment_list_modal.dart';
import 'assignee_modal.dart';
import 'add_issue_form_screen.dart';
import 'issue_details_modal_sheet.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';

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
      return issue.issueName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          issue.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          issue.status.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _showAddIssueDialog({IssueModel? issue}) async {
    final customColors = Theme.of(context).custom;
    final createIssueRepository = ref.read(createIssueRepositoryProvider);
    final updateIssueRepository = ref.read(updateIssueRepositoryProvider);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddIssueFormScreen(
          issue: issue,
          createIssueRepository: createIssueRepository,
          updateIssueRepository: updateIssueRepository,
        ),
      ),
    );

    if (result == true && mounted) {
      ref.invalidate(issueListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            issue == null
                ? 'Issue added successfully'
                : 'Issue updated successfully',
          ),
          backgroundColor: customColors.primary,
        ),
      );
    }
  }

  void _deleteIssue(IssueModel issue) {
    final customColors = Theme.of(context).custom;

    showWarningDialogueBox(
      context: context,
      title: 'Delete Issue',
      subtitle: 'Are you sure you want to delete "${issue.issueName}"? This action cannot be undone.',
      primaryText: 'Delete',
      onPrimaryPressed: (dialogContext) async {
        Navigator.pop(dialogContext);
        try {
          final repository = ref.read(deleteIssueRepositoryProvider);
          await repository.deleteIssue(issue.id);
          ref.invalidate(issueListProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Issue "${issue.issueName}" deleted successfully',
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
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to delete issue: $e',
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
    final customColors = Theme.of(context).custom;

    return Scaffold(
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
            child: ref
                .watch(issueListProvider)
                .when(
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
                              color: customColors.textSecondary!.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No issues yet'
                                  : 'No issues found',
                              style: TextStyle(
                                color: customColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(issueListProvider);
                        await ref.read(issueListProvider.future);
                      },
                      color: customColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredIssues.length,
                        itemBuilder: (context, index) {
                          final issue = filteredIssues[index];
                          final dateFormat = DateFormat('dd/MM/yy');
                          final createdDate = dateFormat.format(
                            issue.createdDate,
                          );
                          final dueDate = issue.dueDate != null
                              ? dateFormat.format(issue.dueDate!)
                              : 'N/A';
                      
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
                                  count:
                                      (issue.assignedTo == null ||
                                          issue.assignedTo!.trim().isEmpty)
                                      ? "0"
                                      : (issue.assignedTo!.split(',').length)
                                            .toString(),
                                  isActive: true,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => AssigneeModal(
                                        assignedTo:
                                            issue.assignedTo ?? 'Unassigned',
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
                                  builder: (context) =>
                                      IssueDetailsModalSheet(issue: issue),
                                );
                              },
                              onEdit: () => _showAddIssueDialog(issue: issue),
                              onDelete: () => _deleteIssue(issue),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => Center(child: DsvLoader()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: customColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading issues',
                          style: TextStyle(
                            color: customColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: TextStyle(
                            color: customColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(issueListProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customColors.primary,
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
        backgroundColor: customColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
