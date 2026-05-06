import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../model/issue_model.dart';
import '../../viewmodel/issue_viewmodel.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/generic_card.dart';
import '../../../../core/widgets/TopBar.dart';
import '../../../../core/models/attachment_list_modal.dart';
import 'assignee_modal.dart';
import 'add_issue_form_screen.dart';
import '../widgets/issue_details_modal_sheet.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';

class IssuesScreen extends ConsumerStatefulWidget {
  const IssuesScreen({super.key});

  @override
  ConsumerState<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends ConsumerState<IssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isRefreshingData = false;
  final List<String> _statusOptions = const [
    'Open',
    'Work In Progress',
    'Resolved',
    'Closed',
  ];

  String _selectedFilter = 'All'; // 'All' or 'Unassigned'
  final List<String> _filterOptions = const ['All', 'Unassigned'];

  List<IssueModel> _filterIssues(List<IssueModel> issues) {
    var filtered = issues;

    // Apply filter selection
    if (_selectedFilter == 'Unassigned') {
      filtered = filtered.where((issue) {
        return issue.assignedTo == null || issue.assignedTo!.trim().isEmpty;
      }).toList();
    }

    // Apply search query
    if (_searchQuery.isEmpty) {
      return filtered;
    }

    return filtered.where((issue) {
      return issue.issueName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          issue.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          issue.status.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

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

  Future<void> _showStatusUpdateDialog(IssueModel issue) async {
    final customColors = Theme.of(context).custom;
    String selectedStatus = issue.status;
    bool isUpdating = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: customColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Update Issue Status',
                style: TextStyle(
                  color: customColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.issueName,
                    style: TextStyle(
                      color: customColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _statusOptions.contains(selectedStatus)
                        ? selectedStatus
                        : _statusOptions.first,
                    dropdownColor: customColors.cardBackground,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(color: customColors.textSecondary),
                      filled: true,
                      fillColor: customColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: customColors.inputBorder!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: customColors.inputBorder!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: customColors.primary!,
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: _statusOptions
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status,
                              style: TextStyle(color: customColors.textPrimary),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: isUpdating
                        ? null
                        : (value) {
                            if (value == null) return;
                            setDialogState(() {
                              selectedStatus = value;
                            });
                          },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: customColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          setDialogState(() {
                            isUpdating = true;
                          });

                          try {
                            final repository = ref.read(
                              updateIssueRepositoryProvider,
                            );
                            await repository.updateIssueStatus(
                              issueId: issue.id,
                              status: selectedStatus,
                            );

                            ref.invalidate(issueListProvider);

                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Issue status updated successfully',
                                  ),
                                  backgroundColor: customColors.primary,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setDialogState(() {
                                isUpdating = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Failed to update status. Please try again.',
                                  ),
                                  backgroundColor: customColors.error,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteIssue(IssueModel issue) {
    final customColors = Theme.of(context).custom;

    showWarningDialogueBox(
      context: context,
      title: 'Delete Issue',
      subtitle:
          'Are you sure you want to delete "${issue.issueName}"? This action cannot be undone.',
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
                        'Failed to delete issue. Try again later.',
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
    final userRole =
        AuthManager.instance.currentUser?.role?.name.toLowerCase() ?? '';
    final connectivityStatus = ref.watch(checkConnectivityProvider);

    return Scaffold(
      floatingActionButton: connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) return null;
          if (ref.watch(issueListProvider).hasError) return null;
          if (userRole != "admin" && userRole != "super admin") return null;
          return FloatingActionButton(
            onPressed: () => _showAddIssueDialog(),
            backgroundColor: customColors.primary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    onInfoTap: () async {
                      if (_isRefreshingData) return;
                      setState(() => _isRefreshingData = true);
                      try {
                        final _ = await ref.refresh(issueListProvider.future);
                        if (mounted) {
                          showSuccessSnackBar(
                            context,
                            'Issues refreshed successfully',
                          );
                        }
                      } catch (e) {
                        debugPrint('Refresh error: $e');
                        if (mounted) {
                          showErrorSnackBar(
                            context,
                            'Refresh failed. Please try again.',
                          );
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
                      onRetry: () => ref.invalidate(checkConnectivityProvider),
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Header
                Column(
                  children: [
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
                      onInfoTap: () async {
                        if (_isRefreshingData) return;
                        setState(() => _isRefreshingData = true);
                        try {
                          final _ = await ref.refresh(issueListProvider.future);
                          if (mounted) {
                            showSuccessSnackBar(
                              context,
                              'Issues refreshed successfully',
                            );
                          }
                        } catch (e) {
                          debugPrint('Refresh error: $e');
                          if (mounted) {
                            showErrorSnackBar(
                              context,
                              'Refresh failed. Please try again.',
                            );
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomSearchBar(
                              controller: _searchController,
                              hintText: 'Search Issues',
                              onChanged: (_) {},
                            ),
                          ),
                          if (userRole == 'admin') const SizedBox(width: 8),
                          if (userRole == 'admin')
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: customColors.inputBorder!,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: customColors.inputFill,
                              ),
                              child: PopupMenuButton<String>(
                                color: customColors.inputFill,
                                onSelected: (value) {
                                  setState(() => _selectedFilter = value);
                                },
                                itemBuilder: (context) => _filterOptions
                                    .map(
                                      (option) => PopupMenuItem<String>(
                                        value: option,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _selectedFilter == option
                                                  ? Icons.radio_button_checked
                                                  : Icons
                                                        .radio_button_unchecked,
                                              color: customColors.primary,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              option,
                                              style: TextStyle(
                                                color: customColors.textPrimary,
                                                fontWeight:
                                                    _selectedFilter == option
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.filter_list,
                                    color: customColors.textPrimary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
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
                                    color: customColors.textSecondary!
                                        .withValues(alpha: 0.5),
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
                                                issue.assignedTo!
                                                    .trim()
                                                    .isEmpty)
                                            ? "0"
                                            : (issue.assignedTo!
                                                      .split(',')
                                                      .length)
                                                  .toString(),
                                        isActive: true,
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => AssigneeModal(
                                              assignedTo:
                                                  issue.assignedTo ??
                                                  'Unassigned',
                                              owner: issue.owner ?? 'N/A',
                                            ),
                                          );
                                        },
                                      ),
                                      CardChip(
                                        icon: Icons.attach_file,
                                        count: issue.attachments.length
                                            .toString(),
                                        isActive: issue.attachments.isNotEmpty,
                                        onTap: issue.attachments.isNotEmpty
                                            ? () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) =>
                                                      AttachmentListModal(
                                                        attachments:
                                                            issue.attachments,
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
                                            IssueDetailsModalSheet(
                                              issue: issue,
                                            ),
                                      );
                                    },
                                    onEdit: () {
                                      if (userRole == 'admin' ||
                                          userRole == 'super admin') {
                                        _showAddIssueDialog(issue: issue);
                                        return;
                                      }
                                      _showStatusUpdateDialog(issue);
                                    },
                                    onDelete:
                                        (userRole == 'admin' ||
                                            userRole == 'super admin')
                                        ? () => _deleteIssue(issue)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => Center(child: DsvLoader()),
                        error: (error, stack) => GlobalError(
                          message: 'Failed to load issues. Please try again.',
                          onRetry: () => ref.invalidate(issueListProvider),
                        ),
                      ),
                ),
              ],
            ),
          );
        },
        error: (error, stack) => GlobalError(
          message: 'Something went wrong. Please check your connection.',
          onRetry: () => ref.invalidate(checkConnectivityProvider),
        ),
        loading: () => const GlobalLoader(message: 'Checking connection...'),
      ),
    );
  }
}
