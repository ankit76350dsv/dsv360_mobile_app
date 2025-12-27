import 'package:dsv360/views/dashboard/AppDrawer.dart';
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
              children: const [
                _ActivitiesTab(),
                _LeaveTab(),
                _AttendanceTab(),
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
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage('assets/avatar.png'), // optional
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
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Yet to check-in',
                  style: TextStyle(color: Colors.redAccent),
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _InfoCard(
          title: 'Good Night Aman Jain',
          subtitle: 'Have a productive night!',
          icon: Icons.person,
          accentColor: Colors.blue,
        ),
        _InfoCard(
          title: 'Check-in reminder',
          subtitle: 'Your shift is completed\n9:00 AM – 7:00 PM',
          icon: Icons.alarm,
          accentColor: Colors.orange,
        ),
        _InfoCard(
          title: 'Work Schedule',
          subtitle: '21 Dec 2025 – 27 Dec 2025',
          icon: Icons.calendar_today,
          accentColor: Colors.blueAccent,
        ),
        _InfoCard(
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
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
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
              childAspectRatio: 1.4,
              children: const [
                LeaveSummaryCard(
                  title: "Remaining",
                  value: "24",
                  subtitle: "Out of 26 leaves",
                  color: Colors.green,
                  icon: Icons.eco,
                ),
                LeaveSummaryCard(
                  title: "Paid",
                  value: "20",
                  subtitle: "Out of 20 leaves",
                  color: Colors.redAccent,
                  icon: Icons.money_off,
                ),
                LeaveSummaryCard(
                  title: "Sick",
                  value: "4",
                  subtitle: "Out of 6 leaves",
                  color: Colors.lightGreen,
                  icon: Icons.local_hospital,
                ),
                LeaveSummaryCard(
                  title: "Unpaid",
                  value: "0",
                  subtitle: "This month",
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text("Request"),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Leave list
            const LeaveTile(
              type: "Unpaid Leave",
              start: "2026-01-01",
              end: "2026-01-07",
              status: "Pending",
            ),
            const LeaveTile(
              type: "Unpaid Leave",
              start: "2025-12-22",
              end: "2025-12-26",
              status: "Pending",
            ),
            const LeaveTile(
              type: "Unpaid Leave",
              start: "2025-12-17",
              end: "2025-12-19",
              status: "Pending",
            ),
            const LeaveTile(
              type: "Paid Leave",
              start: "2025-12-12",
              end: "2025-12-16",
              status: "Pending",
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
          Text(
            title,
            style: TextStyle(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
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

  const LeaveTile({
    super.key,
    required this.type,
    required this.start,
    required this.end,
    required this.status,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "From $start to $end",
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.edit, color: Colors.green),
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
    final theme = Theme.of(context);

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
                        horizontal: 14, vertical: 8),
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
                        Icon(Icons.arrow_drop_down,
                            color: Colors.white),
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
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
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Status
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
