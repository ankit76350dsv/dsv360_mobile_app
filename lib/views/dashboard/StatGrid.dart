import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/app_colors.dart';

class StatGrid extends StatelessWidget {
  final bool isLarge;
  const StatGrid({required this.isLarge});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatCard(title: 'Total Employees', value: '107', icon: Icons.person_outline, color: Colors.indigo),
      _StatCard(title: 'Total Projects', value: '1', icon: Icons.folder_outlined, color: Colors.cyan),
      _StatCard(title: 'Completed Projects', value: '0', icon: Icons.school_outlined, color: Colors.green),
      _StatCard(title: 'Total Issues', value: '0', icon: Icons.bug_report_outlined, color: Colors.orange),
    ];

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: isLarge ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.18),
                  child: Icon(icon, color: color),
                  radius: 18,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}