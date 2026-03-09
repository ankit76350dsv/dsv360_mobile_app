import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/models/dashboard_model.dart';
import 'package:dsv360/repositories/dashboard_repository.dart';
import 'package:dsv360/core/constants/auth_manager.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

// Year selected in the Task Status pie chart picker.
final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

// Year selected in the Project Analytics bar chart picker.
final selectedProjectYearProvider = StateProvider<int>((ref) => DateTime.now().year);

// Initial page load — uses current year, does NOT watch any year picker.
// Only the stats grid and top header depend on this, so the page never
// rebuilds when a chart year is changed.
final dashboardDataProvider = FutureProvider<DashboardModel>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final user = AuthManager.instance.currentUser;
  if (user == null) throw Exception('User not logged in');
  final year = DateTime.now().year.toString();
  return repository.fetchDashboardData(
    userId: user.id,
    orgId: user.zaaid,
    year: year,
  );
});

// Fetches only task-status counts for the selected pie-chart year.
// Only TaskStatusCard watches this — year changes rebuild that card alone.
final taskStatusDataProvider = FutureProvider<YearTaskData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final user = AuthManager.instance.currentUser;
  if (user == null) throw Exception('User not logged in');
  final year = ref.watch(selectedYearProvider).toString();
  final dash = await repository.fetchDashboardData(
    userId: user.id,
    orgId: user.zaaid,
    year: year,
  );
  return dash.yearTaskData;
});

// Fetches only month-wise project data for the selected analytics-chart year.
// Only ProjectAnalyticsCard watches this — year changes rebuild that card alone.
final projectAnalyticsDataProvider = FutureProvider<List<YearMonthProjectData>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final user = AuthManager.instance.currentUser;
  if (user == null) throw Exception('User not logged in');
  final year = ref.watch(selectedProjectYearProvider).toString();
  final dash = await repository.fetchDashboardData(
    userId: user.id,
    orgId: user.zaaid,
    year: year,
  );
  return dash.yearMonthwiseUserProjects;
});

