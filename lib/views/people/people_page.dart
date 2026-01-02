import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/leave_summary.dart';
import 'package:dsv360/models/leave_details.dart';
import 'package:dsv360/models/time_logs.dart';
import 'package:dsv360/repositories/time_logs_repository.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/people/apply_leave_page.dart';
import 'package:dsv360/views/people/leave_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF121212),
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('People'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Column(
        children: [
          /// �️ TABS
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Check In'),
              Tab(text: 'Activities'),
              Tab(text: 'Leave'),
              Tab(text: 'Attendance'),
              Tab(text: 'Attendance Tracker'),
            ],
          ),

          /// 📄 TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _CheckInTab(),
                _ActivitiesTab(),
                _LeaveTab(),
                _AttendanceTab(),
                _AttendanceTrackerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final bool isDark;

  const _ProfileHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.successDark, AppColors.primary],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people,
              color: isDark ? Colors.black : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Aman Jain',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Yet to check-in',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.nightlight_round, color: Colors.white),
        ],
      ),
    );
  }
}

class _ActivitiesTab extends StatelessWidget {
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

  String _getGreetingTitle() {
    final timeOfDay = _getTimeOfDayGreeting();
    return 'Good ${timeOfDay.substring(0, 1).toUpperCase()}${timeOfDay.substring(1)} Aman Jain';
  }

  String _getGreetingSubtitle() {
    final timeOfDay = _getTimeOfDayGreeting();
    return 'Have a productive $timeOfDay!';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: _getGreetingTitle(),
          subtitle: _getGreetingSubtitle(),
          icon: Icons.person,
          accentColor: Colors.blue,
        ),
        const _InfoCard(
          title: 'Check-in reminder',
          subtitle: 'Your shift is completed\n9:00 AM – 7:00 PM',
          icon: Icons.alarm,
          accentColor: Colors.orange,
        ),
        const _InfoCard(
          title: 'Work Schedule',
          subtitle: '21 Dec 2025 – 27 Dec 2025',
          icon: Icons.calendar_today,
          accentColor: Colors.blueAccent,
        ),
        _TimeLogsCard(),
      ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
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
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeLogsCard extends ConsumerWidget {
  const _TimeLogsCard();

  String _extractTime(String dateTime) {
    if (dateTime.isEmpty) return '--:--:--';
    final parts = dateTime.split(' ');
    return parts.length > 1 ? parts[1] : dateTime;
  }

  String _formatTotalTime(String totalTime) {
    final minutes = int.tryParse(totalTime) ?? 0;
    return '$minutes m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeLogsAsync = ref.watch(timeLogsRepositoryProvider);

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
  final List<TimeLogs> timeLogs;

  const _TimeLogsContent({required this.timeLogs});

  // Helper method to extract time from datetime string
  String _extractTime(String dateTime) {
    if (dateTime.isEmpty) return '--:--:--';
    try {
      // Format: "2025-12-31 20:21:38"
      final parts = dateTime.split(' ');
      if (parts.length > 1) {
        return parts[1]; // Returns "20:21:38"
      }
      return dateTime;
    } catch (e) {
      return dateTime;
    }
  }

  // Helper method to format total time
  String _formatTotalTime(String totalTime) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: colors.primary, width: 4)),
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
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
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
                    bottom: BorderSide(
                      color: colors.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _extractTime(log.checkIn),
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        log.checkOut.isNotEmpty
                            ? _extractTime(log.checkOut)
                            : '--:--:--',
                        style: TextStyle(
                          color: log.checkOut.isNotEmpty
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

class _LeaveTab extends StatelessWidget {
  const _LeaveTab();

  @override
  Widget build(BuildContext context) {
    // Mock leave summary data - replace with actual API call
    final leaveSummary = LeaveSummary.fromJson({
      "Remaining_Total_Leaves": "24",
      "Remaining_Paid_Leaves": "20",
      "Remaining_Sick_Leaves": "4",
      "Used_Paid_Leave": "0",
      "Used_Unpaid_Leave": "0",
      "Used_Sick_Leave": "2",
      "Total_Sick_Leave": "6",
      "Total_Paid_Leave": "20",
    });

    // Mock leave details list - replace with actual API call
    final List<LeaveDetails> dummyLeaves = [
      LeaveDetails.fromJson({
        "CREATORID": "1",
        "Status": "Pending",
        "ActionByID": null,
        "Cancellation_Reason": null,
        "End_Date": "2026-01-07",
        "Reason": "Family vacation",
        "ActionBy": null,
        "LeaveCnt": "7",
        "MODIFIEDTIME": "",
        "Username": "Aman Jain",
        "UserID": "101",
        "Leave_Type": "Unpaid_Leave",
        "CREATEDTIME": "2025-12-20",
        "Start_Date": "2026-01-01",
        "ROWID": "1",
      }),
      LeaveDetails.fromJson({
        "CREATORID": "1",
        "Status": "Approved",
        "ActionByID": "200",
        "Cancellation_Reason": null,
        "End_Date": "2025-12-26",
        "Reason": "Travel to hometown",
        "ActionBy": "Manager",
        "LeaveCnt": "5",
        "MODIFIEDTIME": "",
        "Username": "Aman Jain",
        "UserID": "101",
        "Leave_Type": "Unpaid_Leave",
        "CREATEDTIME": "2025-12-15",
        "Start_Date": "2025-12-22",
        "ROWID": "2",
      }),
      LeaveDetails.fromJson({
        "CREATORID": "1",
        "Status": "Rejected",
        "ActionByID": "200",
        "Cancellation_Reason": "Project delivery",
        "End_Date": "2025-12-19",
        "Reason": "Personal work",
        "ActionBy": "Manager",
        "LeaveCnt": "3",
        "MODIFIEDTIME": "",
        "Username": "Aman Jain",
        "UserID": "101",
        "Leave_Type": "Unpaid_Leave",
        "CREATEDTIME": "2025-12-10",
        "Start_Date": "2025-12-17",
        "ROWID": "3",
      }),
      LeaveDetails.fromJson({
        "CREATORID": "1",
        "Status": "Pending",
        "ActionByID": null,
        "Cancellation_Reason": null,
        "End_Date": "2025-12-16",
        "Reason": "Medical checkup",
        "ActionBy": null,
        "LeaveCnt": "5",
        "MODIFIEDTIME": "",
        "Username": "Aman Jain",
        "UserID": "101",
        "Leave_Type": "Paid_Leave",
        "CREATEDTIME": "2025-12-08",
        "Start_Date": "2025-12-12",
        "ROWID": "4",
      }),
    ];

    return Scaffold(
      // backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            GridView.count(
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

            const SizedBox(height: 24),

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Leave Requests",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplyLeavePage(leave: null),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "Request Leave",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Leave list (dummy data based on LeaveDetails model)
            ...dummyLeaves.map(
              (leave) => LeaveTile(
                type: leave.formattedLeaveType,
                start: leave.formattedStartDate,
                end: leave.formattedEndDate,
                status: leave.formattedStatus,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeaveDetailsPage(leave: leave),
                    ),
                  );
                },
                onEditTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplyLeavePage(leave: leave),
                    ),
                  );
                },
              ),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(title, style: TextStyle(color: color)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
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
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "From $start to $end",
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.red.withOpacity(0.1),
                    highlightColor: Colors.red.withOpacity(0.1),
                  ),
                  child: TextButton(
                    onPressed: onEditTap,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.edit, color: Colors.green),
                        ),
                        Text(
                          'EDIT',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 150,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.red.withOpacity(0.1),
                    highlightColor: Colors.red.withOpacity(0.1),
                  ),
                  child: TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'VIEW DETAILS',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: Column(
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
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "This Week",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
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
        ),
      ),
    );
  }
}

class _CheckInTab extends StatefulWidget {
  const _CheckInTab();

  @override
  State<_CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends State<_CheckInTab> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final formattedDate =
        '${_getDayName(now.weekday)}, ${_getMonthName(now.month)} ${now.day}';
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: const BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [Color(0xFF2B2B2B), Color(0xFF1C1C1C)],
        // ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            /// 👤 KEEP PROFILE HEADER AS IS
            _ProfileHeader(isDark: isDark),

            const SizedBox(height: 20),

            /// 📅 CURRENT DATE & TIME INFO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF222222),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'TODAY',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF222222),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'NOW',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ⏱️ TIME ELAPSED SECTION - ENHANCED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.success.withOpacity(0.15),
                      AppColors.success.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: AppColors.success.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TIME ELAPSED',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '00:00:00',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: AppColors.success.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: AppColors.success),
                          const SizedBox(width: 8),
                          Text(
                            'Not Checked In',
                            style: TextStyle(
                              color: AppColors.success,
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

            const SizedBox(height: 20),

            /// 📊 QUICK INFO CARDS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF222222),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.white.withOpacity(0.5),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '9:00 AM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Shift Start',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF222222),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.white.withOpacity(0.5),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '7:00 PM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Shift End',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// 🔽 CHECK-IN BUTTON (BOTTOM, MOBILE FRIENDLY) - ENHANCED
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: trigger check-in
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.login, size: 22, color: Colors.black),
                        SizedBox(width: 12),
                        Text(
                          'CHECK-IN NOW',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: highlight
            ? const LinearGradient(
                colors: [Color(0xFF3A3328), Color(0xFF1F1F1F)],
              )
            : null,
        color: highlight ? null : const Color(0xFF222222),
      ),
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
                Text(
                  date,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Shift Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "General",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "9:00 AM - 7:00 PM",
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
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
    );
  }
}

class _AttendanceTrackerTab extends StatefulWidget {
  const _AttendanceTrackerTab({super.key});

  @override
  State<_AttendanceTrackerTab> createState() => _AttendanceTrackerTabState();
}

class _AttendanceTrackerTabState extends State<_AttendanceTrackerTab> {
  String? selectedEmployee;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  final List<String> employees = ['Aman Jain', 'Abhay Singh', 'Ujjwal Mishra'];

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            'Attendance Tracker',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          /// Employee dropdown
          DropdownButtonFormField<String>(
            value: selectedEmployee,
            decoration: _inputDecoration('Select Employee', colors),
            items: employees
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() => selectedEmployee = value);
            },
          ),
          const SizedBox(height: 16),

          /// Date range + submit
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Start Date',
                  date: startDate,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DateField(
                  label: 'End Date',
                  date: endDate,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Fetch attendance
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// Table header
          _TableHeader(),
          const SizedBox(height: 12),

          /// Empty state
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No attendance records found',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
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

/// Table header row
class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    return Row(
      children: const [
        _HeaderCell('Name'),
        _HeaderCell('Date'),
        _HeaderCell('Check In'),
        _HeaderCell('Check Out'),
        _HeaderCell('Total Time'),
        _HeaderCell('Status'),
      ],
    );
  }
}
