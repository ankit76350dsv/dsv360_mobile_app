import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:dsv360/features/dashboard/view/widgets/AppDrawer.dart';
import 'package:dsv360/features/dashboard/view/widgets/DashboardTitle.dart';
import 'package:dsv360/features/dashboard/view/widgets/ProjectAnalyticsCard.dart';
import 'package:dsv360/features/dashboard/view/widgets/StatGrid.dart';
import 'package:dsv360/features/dashboard/view/widgets/TaskStatusCard.dart';
import 'package:dsv360/features/dashboard/view/widgets/TopHeader.dart';
import 'package:dsv360/features/profile/view/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/profile/cache/image_cache_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _DashboardScaffold();
  }
}

class _DashboardScaffold extends ConsumerWidget {
  const _DashboardScaffold();

  Future<void> _refreshDashboard(WidgetRef ref) async {
    ref.invalidate(taskStatusDataProvider);
    ref.invalidate(projectAnalyticsDataProvider);
    ref.invalidate(dashboardDataProvider);
    final refreshFuture = ref.refresh(dashboardDataProvider.future);
    await refreshFuture;
  }

  Future<ImageProvider?> _getCachedProfileImage() async {
    final file = await ImageCacheService.cachedFileIfExists(
      'cached_profile_image.jpg',
    );
    if (file != null) return FileImage(file);
    return null;
  }

  Widget _buildStatusView({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String message,
    required IconData icon,
  }) {
    final customColors = Theme.of(context).custom;
    debugPrint("refresh pressed");

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: customColors.textPrimary),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: customColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: customColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _refreshDashboard(ref),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = UserManager.instance.userProfile;
    final connectivityStatus = ref.watch(checkConnectivityProvider);
    ref.listen(connectivityStatusProvider, (previous, next) {
      final previousHasNoInternet = previous?.valueOrNull?.contains(ConnectivityResult.none) ?? false;
      final nextHasInternet = next.valueOrNull?.contains(ConnectivityResult.none) == false;

      if (previousHasNoInternet && nextHasInternet) {
        ref.invalidate(checkConnectivityProvider);
        ref.invalidate(taskStatusDataProvider);
        ref.invalidate(projectAnalyticsDataProvider);
        ref.invalidate(dashboardDataProvider);
      }
    });
    final dashboardAsyncValue = ref.watch(dashboardDataProvider);
    final customColors = Theme.of(context).custom;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // Hide default hamburger
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'DSV360',
          style: TextStyle(color: customColors.textPrimary),
        ),
        leadingWidth: 46,
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                margin: const EdgeInsets.only(left: 0.0, top: 8.0, bottom: 8.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: customColors.inputFill,
                  child: Image.asset(
                    'assets/images/dsv.png',
                    width: 25,
                    height: 25,
                  ),
                ),
              ),
            );
          },
        ),
        actions: [
          //Commented Icon Button, will be used in future (Uncommented)

          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (_) => const NotificationPage()),
          //     );
          //   },
          //   icon: Icon(
          //     Icons.notifications_none,
          //     color: customColors.textPrimary,
          //   ),
          // ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            icon: FutureBuilder<ImageProvider?>(
              future: _getCachedProfileImage(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return SizedBox(
                    width: 30,
                    height: 30,
                    child: CircleAvatar(backgroundImage: snapshot.data),
                  );
                }
                if (userProfile?.profileLink != null &&
                    userProfile!.profileLink.isNotEmpty) {
                  return SizedBox(
                    width: 30,
                    height: 30,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userProfile.profileLink),
                    ),
                  );
                }
                return Icon(
                  Icons.account_circle_outlined,
                  color: customColors.textPrimary,
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: connectivityStatus.when(
          data: (results) {
            if (results.contains(ConnectivityResult.none)) {
              return _buildStatusView(
                context: context,
                ref: ref,
                title: 'No internet connection',
                message: 'Please connect to the internet and refresh.',
                icon: Icons.wifi_off_rounded,
              );
            }
            // When connected, show dashboard data
            return dashboardAsyncValue.when(
              skipLoadingOnRefresh: true,
              data: (dashboard) {
                return RefreshIndicator(
                  onRefresh: () async {
                    // Refresh page stats + both chart cards independently.
                    ref.invalidate(taskStatusDataProvider);
                    ref.invalidate(projectAnalyticsDataProvider);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const DashboardTitle(),
                                      const SizedBox(height: 24),
                                      StatGrid(
                                        isLarge: isLarge,
                                        userCnt: dashboard.userCnt,
                                        projectCnt: dashboard.projectCnt,
                                        completedProjectCnt:
                                            dashboard.completedProjectCnt,
                                        issueCnt: dashboard.issueCnt,
                                      ),
                                      const SizedBox(height: 16),
                                      TopHeader(
                                        isLarge: isLarge,
                                        projectCnt: dashboard.projectCnt,
                                        completedProjectCnt:
                                            dashboard.completedProjectCnt,
                                        taskCnt: dashboard.taskCnt,
                                        taskClosedCnt:
                                            dashboard.yearTaskData.closed,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              // No monthData param — card fetches its own data.
                                              child: ProjectAnalyticsCard(),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              flex: 1,
                                              // No taskData param — card fetches its own data.
                                              child: TaskStatusCard(),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            // No monthData/taskData params — cards self-fetch.
                                            ProjectAnalyticsCard(),
                                            const SizedBox(height: 12),
                                            TaskStatusCard(),
                                          ],
                                        ),
                                ),
                              ),

                              // Recent + Quick actions placeholder space
                              SliverToBoxAdapter(
                                child: const SizedBox(height: 40),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              error: (error, stack) => _buildStatusView(
                context: context,
                ref: ref,
                title: 'Failed to load dashboard',
                message: 'Tap refresh to load the data again.',
                icon: Icons.error_outline_rounded,
              ),
              loading: () =>
                  const GlobalLoader(message: 'Loading dashboard...'),
            );
          },
          error: (error, stack) => _buildStatusView(
            context: context,
            ref: ref,
            title: 'Something went wrong',
            message: 'Try refreshing the dashboard.',
            icon: Icons.refresh_rounded,
          ),
          loading: () => const GlobalLoader(message: 'Checking connection...'),
        ),
      ),
    );
  }
}
