import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/leave_summary.dart';
import 'package:dsv360/models/leave_details.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/people/apply_leave_page.dart';
import 'package:dsv360/views/people/leave_details_page.dart';
import 'package:flutter/material.dart';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: const Color(0xFF121212),
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('People'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      /// 🔽 CHECK-IN BUTTON (BEST MOBILE PLACEMENT)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              // TODO: trigger check-in
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'CHECK-IN NOW',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          /// 👤 PROFILE HEADER
          _ProfileHeader(isDark: isDark),

          /// 🗂️ TABS
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Activities'),
              Tab(text: 'Leave'),
              Tab(text: 'Attendance'),
            ],
          ),

          /// 📄 TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_ActivitiesTab(), _LeaveTab(), _AttendanceTab()],
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
        const _InfoCard(
          title: 'Today\'s Time Logs',
          subtitle: 'No check-in/check-out logs found',
          icon: Icons.schedule,
          accentColor: Colors.purple,
        ),
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
      backgroundColor: const Color(0xFF1C1C1C),
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
                      MaterialPageRoute(builder: (_) => ApplyLeavePage(leave: null,)),
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
