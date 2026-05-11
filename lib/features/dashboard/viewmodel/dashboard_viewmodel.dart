import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/dashboard/model/dashboard_model.dart';
import 'package:dsv360/features/dashboard/repositories/dashboard_repository.dart';
import 'package:dsv360/core/cache/user_cache_provider.dart';
import 'package:dsv360/core/constants/auth_manager.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

// Year selected in the Task Status pie chart picker.
final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

// Year selected in the Project Analytics bar chart picker.
final selectedProjectYearProvider = StateProvider<int>((ref) => DateTime.now().year);

/// Resolves userId + orgId: prefers live AuthManager (online), falls back to
/// cached GlobalUser (offline).
(String userId, String orgId) _resolveUserIds(WidgetRef? _ , Ref ref) {
  final live = AuthManager.instance.currentUser;
  if (live != null) return (live.id, live.zaaid.toString());
  final cached = ref.read(globalUserProvider);
  return (cached?.id ?? '', cached?.orgId ?? '');
}

// Initial page load — uses current year, does NOT watch any year picker.
final dashboardDataProvider = FutureProvider<DashboardModel>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final (userId, orgId) = _resolveUserIds(null, ref);
  if (userId.isEmpty) throw Exception('User not logged in');
  final year = DateTime.now().year.toString();
  return repository.fetchDashboardData(userId: userId, orgId: orgId, year: year);
});

// Fetches only task-status counts for the selected pie-chart year.
final taskStatusDataProvider = FutureProvider<YearTaskData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final (userId, orgId) = _resolveUserIds(null, ref);
  if (userId.isEmpty) throw Exception('User not logged in');
  final year = ref.watch(selectedYearProvider).toString();
  final dash = await repository.fetchDashboardData(userId: userId, orgId: orgId, year: year);
  return dash.yearTaskData;
});

// Fetches only month-wise project data for the selected analytics-chart year.
final projectAnalyticsDataProvider = FutureProvider<List<YearMonthProjectData>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final (userId, orgId) = _resolveUserIds(null, ref);
  if (userId.isEmpty) throw Exception('User not logged in');
  final year = ref.watch(selectedProjectYearProvider).toString();
  final dash = await repository.fetchDashboardData(userId: userId, orgId: orgId, year: year);
  return dash.yearMonthwiseUserProjects;
});

