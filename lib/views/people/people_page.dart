import 'dart:async';
import 'package:dsv360/models/leave_summary.dart';
import 'package:dsv360/models/time_logs.dart';
import 'package:dsv360/repositories/leaves_repository.dart';
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
    final theme = Theme.of(context);

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
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color,
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
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: _getGreetingTitle(),
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
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
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

    return Card(
      child: Container(
        decoration: BoxDecoration(
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
    final leaveDetailsListAsync = ref.watch(leaveDetailsListRepositoryProvider);
    final theme = Theme.of(context);

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

    return Scaffold(
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text(
                    "Request Leave",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            leaveDetailsListAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (leaveList) {
                if (leaveList.isEmpty) {
                  return const Center(child: Text('No leave records found'));
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
                    );
                  },
                );
              },
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
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(14),
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
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "From $start to $end",
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
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
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.edit,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            'EDIT',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
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
                  child: TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'VIEW DETAILS',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    'Last Week',
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

class _CheckInTab extends StatefulWidget {
  const _CheckInTab();

  @override
  State<_CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends State<_CheckInTab> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isCheckedIn = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleCheckIn() {
    if (_isCheckedIn) {
      // ⛔ Stop timer
      _timer?.cancel();
    } else {
      // ▶️ Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      });
    }
    setState(() {
      _isCheckedIn = !_isCheckedIn;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Aman Jain',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),

            /// ⏱️ TIME ELAPSED
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
                    colors: [
                      colors.primary.withOpacity(0.15),
                      colors.primary.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: colors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: colors.primary.withOpacity(0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TIME ELAPSED',
                          style: TextStyle(
                            color: colors.primary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _formatDuration(_elapsed),
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: colors.primary.withOpacity(0.5),
                            blurRadius: 15,
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
                        color: colors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: colors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _isCheckedIn ? 'Checked In' : 'Not Checked In',
                            style: TextStyle(
                              color: colors.primary,
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
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: colors.onSurface.withOpacity(0.5),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '9:00 AM',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Shift Start', style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.logout,
                              color: colors.onSurface.withOpacity(0.5),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '7:00 PM',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Shift End', style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleCheckIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(
                        _isCheckedIn
                            ? Icons.logout
                            : Icons
                                  .login, // or Icons.check_circle, Icons.access_time
                        size: 20,
                      ),
                      label: Text(
                        (_isCheckedIn ? 'CHECK OUT' : 'CHECK IN NOW')
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
              color: colors.primary,
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
            ],
          ),

          const SizedBox(height: 30),

          Row(children:[Expanded(
            child:TextButton(
                onPressed: () {
                  // TODO: Fetch attendance
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
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
              ),),]),

              const SizedBox(height: 16),

          // Attendance List
        Expanded(
          child: ListView(

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
