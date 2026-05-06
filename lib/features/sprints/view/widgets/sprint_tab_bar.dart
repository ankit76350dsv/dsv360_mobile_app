import 'package:flutter/material.dart';

class SprintTabBar extends StatelessWidget {
  final TabController tabController;
  final Color tabbarBg;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const SprintTabBar({
    super.key,
    required this.tabController,
    required this.tabbarBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: tabbarBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          height: 44,
          child: TabBar(
            controller: tabController,
            labelColor: textPrimary,
            unselectedLabelColor: textSecondary,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            indicator: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Board'),
              Tab(text: 'Backlog'),
              Tab(text: 'Timeline'),
            ],
          ),
        ),
      ),
    );
  }
}
