import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/custom_search_bar.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/people/model/leave_summary.dart';
import 'package:dsv360/features/people/repositories/leave_summary_repository.dart';
import 'package:dsv360/features/people/repositories/leaves_repository.dart';
import 'package:dsv360/features/people/view/pages/apply_edit_leave_page.dart';
import 'package:dsv360/features/people/view/pages/leave_details_page.dart';
import 'package:dsv360/features/people/view/widgets/leave_summary_card.dart';
import 'package:dsv360/features/people/view/widgets/leave_tile.dart';
import 'package:dsv360/features/people/viewmodel/leave_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveTab extends ConsumerStatefulWidget {
  const LeaveTab({super.key});

  @override
  ConsumerState<LeaveTab> createState() => _LeaveTabState();
}

class _LeaveTabState extends ConsumerState<LeaveTab> {
  late final TextEditingController _searchController;

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

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final userId = activeUser?.userId ?? '';
    final username =
        "${activeUser?.firstName ?? ''} ${activeUser?.lastName ?? ''}".trim();

    final searchQuery = ref.watch(leaveSearchQueryProvider);
    final selectedLeaveType = ref.watch(leaveTypeFilterProvider);

    final leaveDetailsListAsync = ref.watch(leaveDetailsListRepositoryProvider);
    final leaveSummaryAsync = ref.watch(
      leaveSummaryRepositoryProvider((userId: userId, username: username)),
    );

    final customColors = Theme.of(context).custom;
    final connectivityStatus = ref.watch(checkConnectivityProvider);

    return Scaffold(
      body: SafeArea(
        child: connectivityStatus.when(
          data: (results) {
            if (results.contains(ConnectivityResult.none)) {
              return GlobalError(
                message: 'Please check your internet connection.',
                isNetworkError: true,
                onRetry: () {
                  ref.invalidate(checkConnectivityProvider);
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final _ = await ref.refresh(
                  leaveSummaryRepositoryProvider(
                    (userId: userId, username: username),
                  ).future,
                );
                final _ = await ref.refresh(
                  leaveDetailsListRepositoryProvider.future,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (!IsHaveAccess.instance.isAdmin)
                    leaveSummaryAsync.when(
                      loading: () => const GlobalLoader(
                        message: 'Loading leave summary...',
                      ),
                      error: (error, stack) => GlobalError(
                        message:
                            'Failed to load leave summary: Try Again later',
                        onRetry: () => ref.refresh(
                          leaveSummaryRepositoryProvider(
                            (userId: userId, username: username),
                          ),
                        ),
                      ),
                      data: (LeaveSummary leaveSummary) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: LeaveSummaryCard(
                                  title: "Remaining",
                                  value: leaveSummary.remainingValue,
                                  subtitle: leaveSummary.remainingSubtitle,
                                  color: Colors.green,
                                  icon: Icons.eco,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: LeaveSummaryCard(
                                  title: "Paid",
                                  value: leaveSummary.paidValue,
                                  subtitle: leaveSummary.paidSubtitle,
                                  color: Colors.redAccent,
                                  icon: Icons.money_off,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: LeaveSummaryCard(
                                  title: "Sick",
                                  value: leaveSummary.sickValue,
                                  subtitle: leaveSummary.sickSubtitle,
                                  color: Colors.lightGreen,
                                  icon: Icons.local_hospital,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: LeaveSummaryCard(
                                  title: "Unpaid",
                                  value: leaveSummary.unpaidValue,
                                  subtitle: leaveSummary.unpaidSubtitle,
                                  color: Colors.lightBlue,
                                  icon: Icons.beach_access,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (!IsHaveAccess.instance.isAdmin)
                    const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Leave Requests",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (IsHaveAccess.instance.isAdmin) const Spacer(),
                      if (!IsHaveAccess.instance.isAdmin)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ApplyEditLeavePage(leave: null),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200.0),
                              side: BorderSide(
                                width: 2.0,
                                color: customColors.primary!,
                              ),
                            ),
                          ),
                          child: Text(
                            "Request Leave".toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: CustomSearchBar(
                          controller: _searchController,
                          hintText: 'Search by name',
                          onChanged: (value) {
                            ref.read(leaveSearchQueryProvider.notifier).state =
                                value;
                          },
                          onClear: () {
                            ref.read(leaveSearchQueryProvider.notifier).state =
                                '';
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: customColors.surfaceBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: PopupMenuButton<String>(
                          tooltip: selectedLeaveType == null
                              ? 'Filter by leave type'
                              : 'Filter: $selectedLeaveType',
                          onSelected: (value) {
                            if (value == '__all__') {
                              ref
                                  .read(leaveTypeFilterProvider.notifier)
                                  .state = null;
                              _searchController.clear();
                              ref
                                  .read(leaveSearchQueryProvider.notifier)
                                  .state = '';
                              setState(() {});
                            } else {
                              ref
                                  .read(leaveTypeFilterProvider.notifier)
                                  .state = value;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: '__all__',
                              child: Text('All Leave Types'),
                            ),
                            ...leaveTypeOptions.map(
                              (type) => PopupMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ),
                            ),
                          ],
                          icon: Icon(
                            Icons.filter_list,
                            color: selectedLeaveType == null
                                ? Colors.grey
                                : customColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (selectedLeaveType != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text(selectedLeaveType),
                        onDeleted: () {
                          ref
                              .read(leaveTypeFilterProvider.notifier)
                              .state = null;
                          setState(() {});
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  leaveDetailsListAsync.when(
                    loading: () => const GlobalLoader(
                        message: 'Loading leave details...'),
                    error: (error, _) => GlobalError(
                      message: 'Failed to load leave details: Try again later.',
                      onRetry: () =>
                          ref.invalidate(leaveDetailsListRepositoryProvider),
                    ),
                    data: (leaveList) {
                      final q = _normalize(searchQuery);
                      final selectedType = selectedLeaveType == null
                          ? null
                          : _normalize(selectedLeaveType);

                      final filteredLeaveList = leaveList.where((leave) {
                        final nameMatch =
                            q.isEmpty || _normalize(leave.username).contains(q);
                        final leaveTypeMatch = selectedType == null ||
                            _normalize(leave.formattedLeaveType) == selectedType;
                        return nameMatch && leaveTypeMatch;
                      }).toList();

                      if (filteredLeaveList.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Text(
                              (q.isNotEmpty || selectedType != null)
                                  ? 'No leave records match your search/filter.'
                                  : 'No Leave Records Found',
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredLeaveList.length,
                        itemBuilder: (context, index) {
                          final leave = filteredLeaveList[index];
                          return LeaveTile(
                            type: leave.formattedLeaveType,
                            name: leave.username,
                            start: leave.formattedStartDate,
                            end: leave.formattedEndDate,
                            status: leave.formattedStatus,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LeaveDetailsPage(leave: leave),
                                ),
                              );
                            },
                            onEditTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ApplyEditLeavePage(leave: leave),
                                ),
                              );
                            },
                            isAdmin: IsHaveAccess.instance.isAdmin,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
          error: (error, stack) => GlobalError(
            message: 'Failed to check connectivity: Try Again',
            onRetry: () => ref.invalidate(checkConnectivityProvider),
          ),
          loading: () => const GlobalLoader(message: 'Checking connection...'),
        ),
      ),
    );
  }
}
