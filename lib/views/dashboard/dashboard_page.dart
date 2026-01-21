import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/providers/dashboard_provider.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/DashboardTitle.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/views/dashboard/ProjectAnalyticsCard.dart';
import 'package:dsv360/views/dashboard/StatGrid.dart';
import 'package:dsv360/views/dashboard/TaskStatusCard.dart';
import 'package:dsv360/views/dashboard/TopHeader.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:dsv360/views/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _DashboardScaffold();
  }
}


class _DashboardScaffold extends ConsumerWidget {
  const _DashboardScaffold();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final dashboardAsyncValue = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // Hide default hamburger
        title: Text(
          'DSV360 - ${activeUser?.firstName ?? "User"}',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                margin: const EdgeInsets.all(8.0),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.inputFill,
                  child: Icon(
                    Icons.person_outline,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
            icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: connectivityStatus.when(
          data: (results) {
            if (results.contains(ConnectivityResult.none)) {
              return GlobalError(
                message: 'Please check your internet connection.',
                isNetworkError: true,
                onRetry: () {
                   ref.invalidate(connectivityStatusProvider);
                },
              );
            }
            // When connected, show dashboard data
            return dashboardAsyncValue.when(
              data: (dashboard) {
                return RefreshIndicator(
                  onRefresh: () async {
                    // Refetch data
                     return await ref.refresh(dashboardDataProvider.future);
                  },
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isLarge = constraints.maxWidth > 600;
                          return CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const DashboardTitle(),
                                      const SizedBox(height: 24),
                                      StatGrid(
                                        isLarge: isLarge,
                                        userCnt: dashboard.userCnt,
                                        projectCnt: dashboard.projectCnt,
                                        completedProjectCnt: dashboard.completedProjectCnt,
                                        issueCnt: dashboard.issueCnt,
                                      ),
                                      const SizedBox(height: 16),
                                      TopHeader(
                                        isLarge: isLarge,
                                        projectCnt: dashboard.projectCnt,
                                        completedProjectCnt: dashboard.completedProjectCnt,
                                        taskCnt: dashboard.taskCnt,
                                        taskClosedCnt: dashboard.yearTaskData.closed,
                                        issueCnt: dashboard.issueCnt,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      
                              // Analytics + Task status row
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: isLarge
                                      ? Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: ProjectAnalyticsCard(
                                                  monthData: dashboard.yearMonthwiseUserProjects),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                                flex: 1,
                                                child: TaskStatusCard(taskData: dashboard.yearTaskData)),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            ProjectAnalyticsCard(
                                                monthData: dashboard.yearMonthwiseUserProjects),
                                            const SizedBox(height: 12),
                                            TaskStatusCard(taskData: dashboard.yearTaskData),
                                          ],
                                        ),
                                ),
                              ),
                      
                              // Recent + Quick actions placeholder space
                              SliverToBoxAdapter(child: const SizedBox(height: 40)),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              error: (error, stack) => GlobalError(
                message: 'Failed to load dashboard data: $error',
                onRetry: () => ref.refresh(dashboardDataProvider),
              ),
              loading: () => const GlobalLoader(message: 'Loading dashboard...'),
            );
          },
          error: (error, stack) => GlobalError(
            message: 'Failed to check connectivity: $error',
            onRetry: () => ref.invalidate(connectivityStatusProvider),
          ),
          loading: () => const GlobalLoader(message: 'Checking connection...'),
        ),
      ),
    );
  }
}
