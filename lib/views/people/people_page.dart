import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/models/active_user.dart';
import 'package:dsv360/models/leave_calendar_event.dart';
import 'package:dsv360/models/leave_summary.dart';
import 'package:dsv360/models/attendance_detail.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/leave_summary_repository.dart';
import 'package:dsv360/repositories/leaves_repository.dart';
import 'package:dsv360/repositories/time_logs_repository.dart';
import 'package:dsv360/repositories/attendance_tracker_list.dart';
import 'package:dsv360/repositories/check_in_repository.dart';
import 'package:dsv360/repositories/users_repository.dart';

import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/people/apply_edit_leave_page.dart';
import 'package:dsv360/views/people/holiday_calendar_page.dart';
import 'package:dsv360/views/people/leave_details_page.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/single_button.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
import 'package:dsv360/views/widgets/custom_date_field.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PeoplePage extends ConsumerStatefulWidget {
  const PeoplePage({super.key});

  @override
  ConsumerState<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends ConsumerState<PeoplePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        toolbarHeight: 35.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'People',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // if needed can add the icon as well here
        // hook for info action
        // you can open a dialog or screen here
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, size: 18),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HolidayCalendarPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// ️ TABS
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.7), // light grey background
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.all(4.0),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: colors.secondary, // white pill
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: colors.primary,
                unselectedLabelColor: colors.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Check In'),
                  Tab(text: 'Activities'),
                  Tab(text: 'Leave'),
                  Tab(text: 'Attendance'),
                  Tab(text: 'Attendance Tracker'),
                  Tab(text: 'Leave Calendar'),
                ],
              ),
            ),
          ),

          /// 📄 TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CheckInTab(),
                _ActivitiesTab(),
                _LeaveTab(),
                _AttendanceTab(),
                _AttendanceTrackerTab(),
                _LeaveCalendarTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivitiesTab extends ConsumerWidget {
  const _ActivitiesTab();

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else {
      return 'night';
    }
  }

  String _getGreetingTitle(ActiveUserModel? activeUser) {
    final timeOfDay = _getTimeOfDayGreeting();
    return 'Good ${timeOfDay.substring(0, 1).toUpperCase()}${timeOfDay.substring(1)} ${activeUser?.firstName} ${activeUser?.lastName}';
  }

  String _getGreetingSubtitle() {
    final timeOfDay = _getTimeOfDayGreeting();
    return 'Have a productive $timeOfDay!';
  }

  String _getCurrentWeekRange() {
    final now = DateTime.now();
    // Sunday to Saturday range
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    final format = DateFormat('dd MMM yyyy');
    return '${format.format(firstDayOfWeek)} – ${format.format(lastDayOfWeek)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserRepositoryProvider);

    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: _getGreetingTitle(activeUser),
          subtitle: _getGreetingSubtitle(),
          icon: Icons.person,
          accentColor: Colors.blue,
        ),
        _InfoCard(
          title: 'Check-in reminder',
          subtitle: 'Your shift is completed\n9:00 AM – 7:00 PM',
          icon: Icons.alarm,
          accentColor: theme.colorScheme.primary,
        ),
        _WorkScheduleCard(weekRange: _getCurrentWeekRange()),
        _TimeLogsCard(),
      ],
    );
  }
}

class _WorkScheduleCard extends StatelessWidget {
  final String weekRange;

  const _WorkScheduleCard({required this.weekRange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate start of week (Sunday)
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withOpacity(0.1)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: Colors.blueAccent, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text('Work Schedule', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  weekRange,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'General',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Week Days Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final date = startOfWeek.add(Duration(days: index));
                final isToday = date.isAtSameMomentAs(today);
                final dayName = DateFormat('E').format(date); // Sun, Mon...
                final isWeekend = date.weekday == 6 || date.weekday == 7;

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        dayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isToday ? colors.primary : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isToday)
                        Column(
                          children: [
                            Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2,
                              width: 20,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        )
                      else if (isWeekend)
                        Text(
                          'Weekend',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.onSurfaceVariant.withOpacity(0.7),
                          ),
                        )
                      else
                        const SizedBox(height: 18), // Placeholder for spacer
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: accentColor, width: 2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeLogsCard extends ConsumerWidget {
  const _TimeLogsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final userId = activeUser?.userId ?? '';

    // If userId is not available, show empty card or loader
    if (userId.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get today's date in YYYY-MM-DD format
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final timeLogsAsync = ref.watch(
      timeLogsRepositoryProvider(
        userId: userId,
        startDate: todayStr,
        endDate: todayStr,
      ),
    );

    return timeLogsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
      ),
      data: (timeLogs) {
        return _TimeLogsContent(timeLogs: timeLogs);
      },
    );
  }
}

class _TimeLogsContent extends StatelessWidget {
  final List<AttendanceDetail> timeLogs;

  const _TimeLogsContent({required this.timeLogs});

  // Helper method to format time from DateTime
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--:--';
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  // Helper method to format total time
  String _formatTotalTime(String? totalTime) {
    if (totalTime == null || totalTime.isEmpty) return '0 m';
    try {
      final minutes = int.tryParse(totalTime) ?? 0;
      return '$minutes m';
    } catch (e) {
      return '0 m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: colors.primary, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Today's Time Logs",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            /// Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Row(
                children: const [
                  _HeaderCell('Check-In'),
                  _HeaderCell('Check-Out'),
                  _HeaderCell('Total Time', alignRight: true),
                ],
              ),
            ),

            /// Empty or data rows
            if (timeLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No check-in/check-out logs found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...timeLogs.map(
                (log) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colors.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatTime(log.checkIn),
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          log.checkOut != null
                              ? _formatTime(log.checkOut)
                              : '--:--:--',
                          style: TextStyle(
                            color: log.checkOut != null
                                ? colors.error
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatTotalTime(log.totalTime),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final bool alignRight;

  const _HeaderCell(this.text, {this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _LeaveTab extends ConsumerWidget {
  const _LeaveTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final userId = activeUser?.userId ?? '';
    final username =
        "${activeUser?.firstName ?? ''} ${activeUser?.lastName ?? ''}".trim();

    final leaveDetailsListAsync = ref.watch(leaveDetailsListRepositoryProvider);
    final leaveSummaryAsync = ref.watch(
      leaveSummaryRepositoryProvider(userId: userId, username: username),
    );

    final theme = Theme.of(context);
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return Scaffold(
      body: SafeArea(
        child: connectivityStatus.when(
          data: (results) {
            if (results.contains(ConnectivityResult.none)) {
              return GlobalError(
                message: 'Please check your internet connection.',
                isNetworkError: true,
                onRetry: () {
                  ref.invalidate(connectivityStatusProvider);
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.refresh(
                  leaveSummaryRepositoryProvider(
                    userId: userId,
                    username: username,
                  ).future,
                );
                ref.refresh(leaveDetailsListRepositoryProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards
                  leaveSummaryAsync.when(
                    loading: () =>
                        const GlobalLoader(message: 'Loading leave summary...'),
                    error: (error, stack) => GlobalError(
                      message: 'Failed to load leave summary: Try Again later',
                      onRetry: () => ref.refresh(
                        leaveSummaryRepositoryProvider(
                          userId: userId,
                          username: username,
                        ),
                      ),
                    ),
                    data: (LeaveSummary leaveSummary) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        LeaveSummaryCard(
                          title: "Remaining",
                          value: leaveSummary.remainingValue,
                          subtitle: leaveSummary.remainingSubtitle,
                          color: Colors.green,
                          icon: Icons.eco,
                        ),
                        LeaveSummaryCard(
                          title: "Paid",
                          value: leaveSummary.paidValue,
                          subtitle: leaveSummary.paidSubtitle,
                          color: Colors.redAccent,
                          icon: Icons.money_off,
                        ),
                        LeaveSummaryCard(
                          title: "Sick",
                          value: leaveSummary.sickValue,
                          subtitle: leaveSummary.sickSubtitle,
                          color: Colors.lightGreen,
                          icon: Icons.local_hospital,
                        ),
                        LeaveSummaryCard(
                          title: "Unpaid",
                          value: leaveSummary.unpaidValue,
                          subtitle: leaveSummary.unpaidSubtitle,
                          color: Colors.lightBlue,
                          icon: Icons.beach_access,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Leave Requests",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
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
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200.0),
                            side: BorderSide(
                              width: 2.0,
                              color: theme.colorScheme.primary,
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

                  leaveDetailsListAsync.when(
                    loading: () =>
                        const GlobalLoader(message: 'Loading leave details...'),
                    error: (error, _) => GlobalError(
                      message: 'Failed to load leave details: Try again later.',
                      onRetry: () =>
                          ref.refresh(leaveDetailsListRepositoryProvider),
                    ),
                    data: (leaveList) {
                      if (leaveList.isEmpty) {
                        return const Center(
                          child: Text('No leave records found'),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: leaveList.length,
                        itemBuilder: (context, index) {
                          final leave = leaveList[index];

                          return LeaveTile(
                            type: leave.formattedLeaveType,
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
            message: 'Failed to check connectivity: $error',
            onRetry: () => ref.invalidate(connectivityStatusProvider),
          ),
          loading: () => const GlobalLoader(message: 'Checking connection...'),
        ),
      ),
    );
  }
}

class LeaveSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const LeaveSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(title, style: TextStyle(color: color)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaveTile extends StatelessWidget {
  final String type;
  final String start;
  final String end;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;

  const LeaveTile({
    super.key,
    required this.type,
    required this.start,
    required this.end,
    required this.status,
    this.onTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CustomChip(
                  label: status,
                  color: theme.colorScheme.primary,
                  icon: null,
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "From $start",
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                    ),
                    Text(
                      "to $end",
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                child: Row(
                  children: [
                    CustomCardButton(icon: Icons.edit, onTap: onEditTap!),
                    const SizedBox(width: 8),
                    CustomCardButton(icon: Icons.remove_red_eye, onTap: onTap!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab({super.key});

  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  final List<String> options = [
    'This Week',
    'Previous Week',
    'This Month',
    'Last Month',
  ];

  String selected = 'This Week';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Attendance",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final result = await showMenu<String>(
                    context: context,
                    position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                    items: options
                        .map(
                          (e) =>
                              PopupMenuItem<String>(value: e, child: Text(e)),
                        )
                        .toList(),
                  );

                  if (result != null) {
                    setState(() => selected = result);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.primary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selected),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Attendance List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: const [
              AttendanceTile(
                day: "Sun",
                date: "21 Dec",
                status: "Weekend",
                statusColor: Colors.red,
                highlight: true,
              ),
              AttendanceTile(
                day: "Mon",
                date: "22 Dec",
                status: "Absent",
                statusColor: Colors.red,
              ),
              AttendanceTile(
                day: "Tue",
                date: "23 Dec",
                status: "Absent",
                statusColor: Colors.red,
              ),
              AttendanceTile(
                day: "Wed",
                date: "24 Dec",
                status: "Absent",
                statusColor: Colors.red,
              ),
              AttendanceTile(
                day: "Thu",
                date: "25 Dec",
                status: "Absent",
                statusColor: Colors.red,
              ),
              AttendanceTile(
                day: "Fri",
                date: "26 Dec",
                status: "Present",
                statusColor: Colors.green,
              ),
              AttendanceTile(
                day: "Sat",
                date: "27 Dec",
                status: "Weekend",
                statusColor: Colors.red,
                highlight: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckInTab extends ConsumerStatefulWidget {
  const _CheckInTab();

  @override
  ConsumerState<_CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends ConsumerState<_CheckInTab> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleAction({
    required String userId,
    required String username,
    AttendanceDetail? activeLog,
  }) async {
    final loadingNotifier = ref.read(
      singleButtonLoadingProvider('checkInCheckOutButton').notifier,
    );
    loadingNotifier.state = true;

    try {
      final now = DateTime.now();
      final dayDate = DateFormat('yyyy-MM-dd').format(now);
      final checkInRepo = ref.read(checkInRepositoryProvider.notifier);

      if (activeLog == null) {
        // Check In
        await checkInRepo.checkIn(
          userId: userId,
          username: username,
          device: 'test-phone', // device id
          lat: 30.75396137744414,
          long: 76.62712840213943,
          dayDate: dayDate,
        );
      } else {
        // Check Out
        await checkInRepo.checkOut(
          device: 'test-phone',
          lat: 30.75396137744414,
          long: 76.62712840213943,
          checkInTimestamp: activeLog.checkIn.millisecondsSinceEpoch,
          rowId: activeLog.rowId ?? '',
        );
      }

      // Invalidate both repositories to refresh UI
      ref.invalidate(timeLogsRepositoryProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      loadingNotifier.state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final userId = activeUser?.userId ?? '';
    final username =
        "${activeUser?.firstName ?? ''} ${activeUser?.lastName ?? ''}".trim();

    if (userId.isEmpty) {
      return const Center(child: GlobalLoader(message: 'Loading user info...'));
    }

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final timeLogsAsync = ref.watch(
      timeLogsRepositoryProvider(
        userId: userId,
        startDate: todayStr,
        endDate: todayStr,
      ),
    );

    return timeLogsAsync.when(
      loading: () => const Center(child: GlobalLoader()),
      error: (err, st) => Center(child: Text('Error: $err')),
      data: (logs) {
        // Find if there's an active session (checkOut is null)
        AttendanceDetail? activeLog;
        try {
          activeLog = logs.firstWhere((log) => log.checkOut == null);
        } catch (_) {
          activeLog = null;
        }

        final isCheckedIn = activeLog != null;
        _elapsed = isCheckedIn
            ? DateTime.now().difference(activeLog.checkIn)
            : Duration.zero;

        return Container(
          decoration: const BoxDecoration(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    username,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),

                /// TIME ELAPSED
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: colors.tertiary.withOpacity(0.9),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'TIME ELAPSED',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _TimeBox(value: _elapsed.inDays, label: "Days"),
                              _TimeBox(
                                value: _elapsed.inHours % 24,
                                label: "Hrs",
                              ),
                              _TimeBox(
                                value: _elapsed.inMinutes % 60,
                                label: "Mins",
                              ),
                              _TimeBox(
                                value: _elapsed.inSeconds % 60,
                                label: "Secs",
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isCheckedIn
                                  ? colors.primary.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: isCheckedIn
                                      ? colors.primary
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isCheckedIn ? 'Checked In' : 'Not Checked In',
                                  style: TextStyle(
                                    color: isCheckedIn
                                        ? colors.primary
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleButton(
                    loadingKey: 'checkInCheckOutButton',
                    text: isCheckedIn ? 'CHECK OUT' : 'CHECK IN NOW',
                    onPressed: () => _handleAction(
                      userId: userId,
                      username: username,
                      activeLog: activeLog,
                    ),
                    icon: isCheckedIn ? Icons.logout : Icons.login,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _TimeBox extends StatelessWidget {
  final int value;
  final String label;

  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: colors.tertiary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            color: colors.tertiary,
          ),
        ),
      ],
    );
  }
}

class AttendanceTile extends StatelessWidget {
  final String day;
  final String date;
  final String status;
  final Color statusColor;
  final bool highlight;

  const AttendanceTile({
    super.key,
    required this.day,
    required this.date,
    required this.status,
    required this.statusColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Day & Date
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(date, style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            // Shift Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "General",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text("9:00 AM - 7:00 PM", style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            // Status
            Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTrackerTab extends ConsumerStatefulWidget {
  const _AttendanceTrackerTab({super.key});

  @override
  ConsumerState<_AttendanceTrackerTab> createState() =>
      _AttendanceTrackerTabState();
}

class _AttendanceTrackerTabState extends ConsumerState<_AttendanceTrackerTab> {
  String? selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _queryUserId;
  String? _queryStartDate;
  String? _queryEndDate;

  final List<String> employees = ['Aman Jain', 'Abhay Singh', 'Ujjwal Mishra'];

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final usersAsync = ref.watch(usersRepositoryProvider);
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return connectivityStatus.when(
      loading: () => const GlobalLoader(message: 'Checking connection...'),
      error: (err, stack) => Center(
        child: GlobalError(
          message: 'Failed to check connectivity: Try Again',
          onRetry: () => ref.invalidate(connectivityStatusProvider),
        ),
      ),
      data: (results) {
        if (results.contains(ConnectivityResult.none)) {
          return GlobalError(
            message: 'Please check your internet connection.',
            isNetworkError: true,
            onRetry: () {
              ref.invalidate(connectivityStatusProvider);
            },
          );
        }

        return usersAsync.when(
          loading: () => const GlobalLoader(message: 'Loading users info...'),
          error: (error, stack) => GlobalError(
            message: 'Failed to load users data: $error',
            onRetry: () => ref.refresh(usersRepositoryProvider),
          ),
          data: (users) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    'Attendance Tracker',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Employee dropdown
                  CustomDropDownField(
                    options: users.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.userId,
                        child: Text('${u.firstName} ${u.lastName}'.trim()),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedEmployeeId = value),
                    hintText: 'Select Employee',
                    labelText: 'Select Employee',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  /// Date range + submit
                  Row(
                    children: [
                      Expanded(
                        child: CustomPickerField(
                          label: 'Start Date',
                          valueText: _startDate == null
                              ? null
                              : DateFormat('dd/MM/yyyy').format(_startDate!),
                          placeholder: 'dd/mm/yyyy',
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 8.0),

                      /// End Date
                      Expanded(
                        child: CustomPickerField(
                          label: 'End Date',
                          valueText: _endDate == null
                              ? null
                              : DateFormat('dd/MM/yyyy').format(_endDate!),
                          placeholder: 'dd/mm/yyyy',
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: SingleButton(
                      loadingKey: 'attendance_tracker',
                      text: 'submit',
                      icon: Icons.assignment_turned_in_sharp,
                      onPressed: () {
                        if (selectedEmployeeId == null ||
                            _startDate == null ||
                            _endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select employee and dates'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _queryUserId = selectedEmployeeId;
                          _queryStartDate = DateFormat(
                            'yyyy-MM-dd',
                          ).format(_startDate!);
                          _queryEndDate = DateFormat(
                            'yyyy-MM-dd',
                          ).format(_endDate!);
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Attendance List
                  Expanded(
                    child:
                        (_queryUserId == null ||
                            _queryStartDate == null ||
                            _queryEndDate == null)
                        ? const Center(
                            child: Text(
                              "Select employee and dates to view attendance",
                            ),
                          )
                        : ref
                              .watch(
                                attendanceTrackerListRepositoryProvider(
                                  userId: _queryUserId!,
                                  startDate: _queryStartDate!,
                                  endDate: _queryEndDate!,
                                ),
                              )
                              .when(
                                data: (attendanceList) {
                                  if (attendanceList.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "No attendance records found",
                                      ),
                                    );
                                  }
                                  return RefreshIndicator(
                                    onRefresh: () async {
                                      ref.refresh(
                                        attendanceTrackerListRepositoryProvider(
                                          userId: _queryUserId!,
                                          startDate: _queryStartDate!,
                                          endDate: _queryEndDate!,
                                        ),
                                      );
                                    },
                                    child: ListView.builder(
                                      itemCount: attendanceList.length,
                                      itemBuilder: (context, index) {
                                        final detail = attendanceList[index];
                                        final date =
                                            DateTime.tryParse(detail.dayDate) ??
                                            detail.checkIn;

                                        return AttendanceTile(
                                          day: DateFormat('EEE').format(date),
                                          date: DateFormat(
                                            'd MMM',
                                          ).format(date),
                                          status: detail.checkOut != null
                                              ? "Present"
                                              : "P (In)",
                                          statusColor: detail.checkOut != null
                                              ? Colors.green
                                              : Colors.orange,
                                        );
                                      },
                                    ),
                                  );
                                },
                                loading: () => const GlobalLoader(
                                  message: 'Loading attendance info...',
                                ),
                                error: (error, stack) => GlobalError(
                                  message:
                                      'Failed to load attendance data: $error',
                                  onRetry: () => ref.refresh(
                                    attendanceTrackerListRepositoryProvider(
                                      userId: _queryUserId!,
                                      startDate: _queryStartDate!,
                                      endDate: _queryEndDate!,
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, ColorScheme colors) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      filled: true,
      fillColor: colors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

/// Date field widget
class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.onSurfaceVariant),
          filled: true,
          fillColor: colors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: TextStyle(color: colors.onSurface),
        ),
      ),
    );
  }
}

class _LeaveCalendarTab extends ConsumerStatefulWidget {
  const _LeaveCalendarTab();

  @override
  ConsumerState<_LeaveCalendarTab> createState() => _LeaveCalendarTabState();
}

class _LeaveCalendarTabState extends ConsumerState<_LeaveCalendarTab> {
  int? _selectedDay;
  List<LeaveCalendarEvent>? _selectedLeaves;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final leadDays = firstDayOfMonth.weekday % 7; // Sunday start logic

    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final calendarAsync = ref.watch(leaveCalendarRepositoryProvider);

    return connectivityStatus.when(
      data: (results) {
        if (results.contains(ConnectivityResult.none)) {
          return GlobalError(
            message: 'Please check your internet connection.',
            isNetworkError: true,
            onRetry: () {
              ref.invalidate(connectivityStatusProvider);
            },
          );
        }

        return calendarAsync.when(
          data: (calendarEvents) {
            // Transform API data to Calendar Map (Optimized)
            final Map<int, List<LeaveCalendarEvent>> mappedLeaves = {};
            for (var item in calendarEvents) {
              final start = DateTime.tryParse(item.startDate);
              final end = DateTime.tryParse(item.endDate);

              if (start == null || end == null) continue;

              // Calculate intersection with current month
              final monthStart = DateTime(year, month, 1);
              final monthEnd = DateTime(year, month + 1, 0);

              // Skip if leave is entirely outside the current month
              if (end.isBefore(monthStart) || start.isAfter(monthEnd)) continue;

              // Start from the later of leave start or month start
              var current = start.isBefore(monthStart) ? monthStart : start;
              // End at the earlier of leave end or month end
              final loopEnd = end.isAfter(monthEnd) ? monthEnd : end;

              while (current.isBefore(loopEnd) ||
                  current.isAtSameMomentAs(loopEnd)) {
                if (current.month == month && current.year == year) {
                  mappedLeaves.putIfAbsent(current.day, () => []).add(item);
                }
                current = current.add(const Duration(days: 1));
              }
            }

            final theme = Theme.of(context);

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(leaveCalendarRepositoryProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave Calendar',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(now),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8,
                    children: [
                      _LegendChip('Sick Leave', const Color(0xFFFACC15)),
                      _LegendChip('Paid Leave', const Color(0xFF2DD4BF)),
                      _LegendChip('Unpaid Leave', const Color(0xFFF87171)),
                      _LegendChip('Others', const Color(0xFF94A3B8)),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Days Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  // Calendar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: daysInMonth + leadDays,
                    itemBuilder: (context, index) {
                      if (index < leadDays) {
                        return const SizedBox();
                      }
                      final day = index - leadDays + 1;
                      final leaves = mappedLeaves[day] ?? [];
                      final isToday =
                          day == now.day &&
                          month == now.month &&
                          year == now.year;
                      final isSelected = _selectedDay == day;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDay = day;
                            _selectedLeaves = leaves;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  )
                                : isToday
                                ? Border.all(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.5),
                                    width: 1.5,
                                  )
                                : Border.all(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.1),
                                  ),
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.05)
                                : null,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$day',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isToday
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (leaves.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.05),
                                      ),
                                      child: Text(
                                        '${leaves.length}',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (isToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1D4ED8,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Today',
                                    style: TextStyle(
                                      color: Color(0xFF3B82F6),
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              if (leaves.isEmpty)
                                Text(
                                  'No leaves',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.4),
                                    fontSize: 7,
                                  ),
                                )
                              else ...[
                                Wrap(
                                  spacing: 3,
                                  runSpacing: 3,
                                  children: leaves
                                      .map(
                                        (l) =>
                                            _Dot(_getLeaveColor(l.leaveType)),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // show the leave list details here the day
                  const SizedBox(height: 24),
                  if (_selectedDay != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Leaves on day $_selectedDay',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_selectedLeaves == null ||
                              _selectedLeaves!.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.05),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 40,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.2),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No leaves scheduled for this day',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedLeaves!.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final leaf = _selectedLeaves![index];
                                final color = _getLeaveColor(leaf.leaveType);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.05),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: color,
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      leaf.username,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            leaf.leaveType.replaceAll('_', ' '),
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${leaf.startDate} to ${leaf.endDate}',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Click on any day to see details',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.touch_app_outlined,
                              size: 48,
                              color: theme.colorScheme.primary.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select a day to view leaves',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () =>
              const Center(child: GlobalLoader(message: 'Loading calendar...')),
          error: (err, stack) => Center(
            child: GlobalError(
              message: 'Failed to load calendar: $err',
              onRetry: () => ref.refresh(leaveCalendarRepositoryProvider),
            ),
          ),
        );
      },
      loading: () => const GlobalLoader(message: 'Checking connection...'),
      error: (err, stack) => Center(
        child: GlobalError(
          message: 'Failed to check connectivity: Try Again',
          onRetry: () => ref.invalidate(connectivityStatusProvider),
        ),
      ),
    );
  }

  Color _getLeaveColor(String type) {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('sick')) {
      return const Color(0xFFFACC15);
    } else if (typeLower.contains('paid')) {
      return const Color(0xFF2DD4BF);
    } else if (typeLower.contains('unpaid')) {
      return const Color(0xFFF87171);
    } else {
      return const Color(0xFF94A3B8);
    }
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
