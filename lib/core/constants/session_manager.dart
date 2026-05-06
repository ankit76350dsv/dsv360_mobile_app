import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:dsv360/features/feedback/viewmodel/feedback_viewmodel.dart';
import 'package:dsv360/features/projects/viewmodel/project_viewmodel.dart';
import 'package:dsv360/features/issues/viewmodel/issue_viewmodel.dart';
import 'package:dsv360/features/task/viewmodel/task_viewmodel.dart';
import 'package:dsv360/features/users/viewmodel/employee_viewmodel.dart';
import 'package:dsv360/features/time_entry/viewmodel/time_entry_viewmodel.dart';
import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/features/projects/repositories/organization_repository.dart';
import 'package:dsv360/features/accounts/viewmodel/accounts_list_viewmodel.dart';
import 'package:dsv360/features/people/repositories/leaves_repository.dart';
import 'package:dsv360/features/users/repositories/users_repository.dart';
import 'package:dsv360/features/people/repositories/holiday_repository.dart';
import 'package:dsv360/features/people/repositories/user_check_in_status_repository.dart';
import 'package:dsv360/features/badges/viewmodel/badge_image_viewmodel.dart';
import 'package:dsv360/features/client/repositories/client_contacts_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized logout handler.
/// Call [logout] from any widget that has a [BuildContext] inside the
/// [ProviderScope] tree. This clears ALL cached state — singletons, Riverpod
/// providers, and the Flutter image cache — so the next login starts fresh.
class SessionManager {
  SessionManager._();

  static Future<void> logout(BuildContext context) async {
    // 1. Catalyst SDK logout (revokes server-side session).
    await AppInitManager.instance.catalystApp.logout();

    // 2. Clear singleton caches.
    TokenManager.instance.clearToken();
    UserManager.instance.clear();
    AuthManager.instance.currentUser = null;

    // 3. Flush Flutter's in-memory image cache (profile photos, etc.).
    PaintingBinding.instance.imageCache.clear();

    // Providers are intentionally NOT invalidated here.
    // Invalidation happens in LoadingPage._fetchUserData() — after the new
    // user is authenticated but before DashboardPage is mounted. That is the
    // only safe moment: user is valid, no active listeners, no re-fetch race.
  }

  /// Public access for [ApiClient._forceLogout] which has no BuildContext.
  static void invalidateAllProviders(ProviderContainer container) {
    _invalidateAllProviders(container);
  }

  static void _invalidateAllProviders(ProviderContainer container) {
    // -- providers/ --------------------------------------------------------
    container.invalidate(dashboardDataProvider);
    container.invalidate(taskStatusDataProvider);
    container.invalidate(projectAnalyticsDataProvider);
    container.invalidate(selectedYearProvider);
    container.invalidate(selectedProjectYearProvider);

    container.invalidate(projectListProvider);

    container.invalidate(issueListProvider);

    container.invalidate(employeeListProvider);

    container.invalidate(currentUserIdProvider);
    container.invalidate(tasksSearchQueryProvider);

    container.invalidate(timerStatusProvider);

    // -- repositories/ -----------------------------------------------------
    container.invalidate(activeUserRepositoryProvider);
    container.invalidate(organizationListRepositoryProvider);
    container.invalidate(organizationSearchQueryProvider);
    container.invalidate(accountsListRepositoryProvider);
    container.invalidate(accountsSearchQueryProvider);
    container.invalidate(feedbackRepositoryProvider);
    container.invalidate(feedbackSearchQueryProvider);
    container.invalidate(leaveDetailsListRepositoryProvider);
    container.invalidate(leaveCalendarRepositoryProvider);
    container.invalidate(usersRepositoryProvider);
    container.invalidate(usersSearchQueryProvider);
    container.invalidate(holidayRepositoryProvider);
    container.invalidate(selectedLocationProvider);
    container.invalidate(userStatusRepositoryProvider);
    container.invalidate(allDSVBadgesListRepositoryProvider);
    container.invalidate(clientContactsListRepositoryProvider);
    container.invalidate(clientContactsSearchQueryProvider);
  }
}
