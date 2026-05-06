import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/dashboard/view/widgets/AppDrawer.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/features/people/view/pages/holiday_calendar_page.dart';
import 'package:dsv360/features/people/view/widgets/activities_tab.dart';
import 'package:dsv360/features/people/view/widgets/attendance_tab.dart';
import 'package:dsv360/features/people/view/widgets/attendance_tracker_tab.dart';
import 'package:dsv360/features/people/view/widgets/check_in_tab.dart';
import 'package:dsv360/features/people/view/widgets/leave_calendar_tab.dart';
import 'package:dsv360/features/people/view/widgets/leave_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    _tabController = TabController(
      length: IsHaveAccess.instance.isManager ? 6 : 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final connectivityStatus = ref.watch(checkConnectivityProvider);

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
        title: const Text(
          'People',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
      body: connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) {
            return GlobalError(
              message: 'Please check your internet connection.',
              isNetworkError: true,
              onRetry: () => ref.invalidate(checkConnectivityProvider),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: customColors.tabbarBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: customColors.tabbarIndicator,
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
                    labelColor: customColors.textPrimary,
                    unselectedLabelColor: customColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    dividerColor: Colors.transparent,
                    tabs: [
                      const Tab(text: 'Check In'),
                      if (!IsHaveAccess.instance.isAdmin ||
                          IsHaveAccess.instance.isManager)
                        const Tab(text: 'Activities'),
                      const Tab(text: 'Leave'),
                      if (!IsHaveAccess.instance.isAdmin ||
                          IsHaveAccess.instance.isManager)
                        const Tab(text: 'Attendance'),
                      if (IsHaveAccess.instance.isAdmin ||
                          IsHaveAccess.instance.isManager)
                        const Tab(text: 'Attendance Tracker'),
                      if (IsHaveAccess.instance.isAdmin ||
                          IsHaveAccess.instance.isManager)
                        const Tab(text: 'Leave Calendar'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const CheckInTab(),
                    if (!IsHaveAccess.instance.isAdmin ||
                        IsHaveAccess.instance.isManager)
                      const ActivitiesTab(),
                    const LeaveTab(),
                    if (!IsHaveAccess.instance.isAdmin ||
                        IsHaveAccess.instance.isManager)
                      const AttendanceTab(),
                    if (IsHaveAccess.instance.isAdmin ||
                        IsHaveAccess.instance.isManager)
                      const AttendanceTrackerTab(),
                    if (IsHaveAccess.instance.isAdmin ||
                        IsHaveAccess.instance.isManager)
                      const LeaveCalendarTab(),
                  ],
                ),
              ),
            ],
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
