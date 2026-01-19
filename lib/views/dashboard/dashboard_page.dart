import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/DashboardTitle.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
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

  // const theme = dark;

  // const theme = light;

  @override
  Widget build(BuildContext context) {
    // This page is a self-contained MaterialApp like your NotificationPage,
    // so it will use the same dark theme and constrained centered layout.
    // return MaterialApp(
    //   title: 'DSV-360 Dashboard',
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData.dark().copyWith(
    //     scaffoldBackgroundColor: const Color(0xFF0B0B0D),
    //     cardColor: const Color(0xFF0F1113),
    //     appBarTheme: const AppBarTheme(
    //       backgroundColor: Colors.transparent,
    //       elevation: 0,
    //       centerTitle: false,
    //       titleTextStyle: TextStyle(
    //         color: Colors.white,
    //         fontSize: 18,
    //         fontWeight: FontWeight.w600,
    //       ),
    //       iconTheme: IconThemeData(color: Colors.white),
    //     ),
    //   ),
    //   home: const _DashboardScaffold(),
    // );
    return _DashboardScaffold();
  }
}

class _DashboardScaffold extends ConsumerWidget {
  const _DashboardScaffold();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserRepositoryProvider);

    // keep the drawer and navigation behavior the same as before
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // Hide default hamburger
        title: Text(
          'DSV360 - ${activeUser?.firstName ?? "User"}',
        ),
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                margin: const EdgeInsets.all(8.0),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white12,
                  child: Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Colors.white,
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
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Center(
          // Constrain the content width to match NotificationPage look & feel
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
                            // TopHeader(isLarge: isLarge),
                            // const SizedBox(height: 16),
                            StatGrid(isLarge: isLarge),
                            const SizedBox(height: 16),
                            TopHeader(isLarge: isLarge),
                            // const SizedBox(height: 16),
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
                                children: const [
                                  Expanded(
                                    flex: 2,
                                    child: ProjectAnalyticsCard(),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(flex: 1, child: TaskStatusCard()),
                                ],
                              )
                            : Column(
                                children: const [
                                  ProjectAnalyticsCard(),
                                  SizedBox(height: 12),
                                  TaskStatusCard(),
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
      ),
    );
  }
}
