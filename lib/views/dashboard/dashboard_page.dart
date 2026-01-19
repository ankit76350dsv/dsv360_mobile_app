import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/ProjectAnalyticsCard.dart';
import 'package:dsv360/views/dashboard/StatGrid.dart';
import 'package:dsv360/views/dashboard/TaskStatusCard.dart';
import 'package:dsv360/views/dashboard/TopHeader.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // const theme = dark;

  // const theme = light;

  @override
  Widget build(BuildContext context) {
    // This page is a self-contained MaterialApp like your NotificationPage,
    // so it will use the same dark theme and constrained centered layout.
    return MaterialApp(
      title: 'DSV-360 Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0D),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const _DashboardScaffold(),
    );
  }
}

class _DashboardScaffold extends StatelessWidget {
  const _DashboardScaffold();

  @override
  Widget build(BuildContext context) {
    // keep the drawer and navigation behavior the same as before
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // Hide default hamburger
        title: const Text('DSV-360'),
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                margin: const EdgeInsets.all(8.0),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.person_outline, size: 18, color: Colors.white),
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationPage(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none),
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
                          children: [
                            TopHeader(isLarge: isLarge),
                            const SizedBox(height: 16),
                            StatGrid(isLarge: isLarge),
                            const SizedBox(height: 16),
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
                                  Expanded(flex: 2, child: ProjectAnalyticsCard()),
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
