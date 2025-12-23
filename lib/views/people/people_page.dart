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
      backgroundColor: const Color(0xFF121212),
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
    return const Center(
      child: Text('Leave details coming soon'),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Attendance history coming soon'),
    );
  }
}
