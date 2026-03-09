import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/dashboard_model.dart';
import 'package:dsv360/providers/dashboard_provider.dart'; // for selectedProjectYearProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerWidget + WidgetRef
// import 'package:dsv360/core/constants/app_colors.dart';

// Changed StatelessWidget → ConsumerWidget to support its own year picker.
// No monthData param — the card fetches its own data via projectAnalyticsDataProvider.
class ProjectAnalyticsCard extends ConsumerWidget {
  const ProjectAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // constrain chart height so it doesn't overflow on small devices
    final chartHeight = MediaQuery.of(context).size.height * 0.35;
    final customColors = Theme.of(context).custom;

    // Read the analytics card's own selected year.
    final selectedYear = ref.watch(selectedProjectYearProvider);

    // Same year list as TaskStatusCard.
    final currentYear = DateTime.now().year;
    final years = List.generate(2, (i) => currentYear - i);

    // Watch analytics-specific provider — only this card rebuilds when year changes.
    final analyticsAsync = ref.watch(projectAnalyticsDataProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: customColors.inputFill,
                child: Icon(Icons.bar_chart, color: customColors.textPrimary),
              ),
              title: Text(
                'Project Analytics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: customColors.textPrimary,
                ),
              ),
              // Same PopupMenuButton pattern as TaskStatusCard — writes to selectedProjectYearProvider.
              trailing: PopupMenuButton<int>(
                initialValue: selectedYear,
                onSelected: (year) =>
                    ref.read(selectedProjectYearProvider.notifier).state = year,
                itemBuilder: (_) => years
                    .map((y) => PopupMenuItem(value: y, child: Text('$y')))
                    .toList(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$selectedYear',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: customColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down,
                      color: customColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // when() renders loader/error/data inline — page is never touched.
            analyticsAsync.when(
              data: (monthData) => SizedBox(
                height: chartHeight,
                child: ListView.separated(
                  itemCount: monthData.length,
                  separatorBuilder: (ctx, i) =>
                      Divider(color: customColors.divider),
                  itemBuilder: (context, index) {
                    if (index >= monthData.length) return const SizedBox.shrink();
                    return _MonthAnalyticsRow(
                      monthIndex: index,
                      data: monthData[index],
                    );
                  },
                ),
              ),
              loading: () => SizedBox(
                height: chartHeight,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => const SizedBox(
                height: 80,
                child: Center(child: Text('Failed to load')),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: customColors.statusCompleted!, label: 'Open'),
                const SizedBox(width: 8),
                _LegendDot(color: customColors.statusInProgress!, label: 'Working'),
                const SizedBox(width: 8),
                _LegendDot(color: customColors.error!, label: 'Closed'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthAnalyticsRow extends StatelessWidget {
  final int monthIndex;
  final YearMonthProjectData data;

  const _MonthAnalyticsRow({required this.monthIndex, required this.data});

  @override
  Widget build(BuildContext context) {
    final open = data.open.toDouble();
    final working = data.inProgress.toDouble();
    final closed = data.closed.toDouble();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    // Safe lookup
    final monthName = (monthIndex >= 0 && monthIndex < months.length)
        ? months[monthIndex]
        : '';

    final customColors = Theme.of(context).custom;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              monthName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: customColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HorizontalBar(
                  label: 'Open',
                  value: open,
                  color: customColors.statusCompleted!,
                ),
                const SizedBox(height: 4),
                _HorizontalBar(
                  label: 'Working',
                  value: working,
                  color: customColors.statusInProgress!,
                ),
                const SizedBox(height: 4),
                _HorizontalBar(
                  label: 'Closed',
                  value: closed,
                  color: customColors.error!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _HorizontalBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // scale factor to fit bars nicely (max val is around 9-10)
    final barWidth = (value / 12) * 200.0;
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: barWidth,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.toInt()}',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: customColors.textSecondary),
        ),
      ],
    );
  }
}
