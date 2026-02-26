import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/models/dashboard_model.dart';
import 'package:dsv360/repositories/dashboard_repository.dart';
import 'package:dsv360/core/constants/auth_manager.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

// Using keepAlive: true to cache the data as requested
final dashboardDataProvider = FutureProvider<DashboardModel>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  
  // Get current user details
  final user = AuthManager.instance.currentUser;
  
  if (user == null) {
    throw Exception('User not logged in');
  }

  // Year Logic:
  final year = DateTime.now().year.toString();
  // final year ='2025';
  
  return repository.fetchDashboardData(
    userId: user.id,
    orgId: user.zaaid,  
    year: year,
  );
});
