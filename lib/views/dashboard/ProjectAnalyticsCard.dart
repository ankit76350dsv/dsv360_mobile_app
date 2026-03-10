import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/dashboard_model.dart';
import 'package:dsv360/providers/dashboard_provider.dart'; // for selectedProjectYearProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerWidget + WidgetRef

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
              // Premium year picker — same pattern as TaskStatusCard, dark-mode aware.
              trailing: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: const Color.fromARGB(0, 255, 119, 119),
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: PopupMenuButton<String>(
                  // ─── POPUP MENU BACKGROUND COLOR ───────────────────────────────
                  // This uses the same color as the Card widget (cardBackground).
                  // To change it, edit the values in lib/core/constants/app_colors.dart:
                  //   • Light mode: AppColorsLight.cardBackground  (default: 0xFFFFFFFF)
                  //   • Dark mode:  AppColorsDark.cardBackground   (default: 0xFF1E1E1E)
                  // ───────────────────────────────────────────────────────────────
                  color: customColors.cardBackground,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.10),
                  offset: const Offset(0, 8),
                  constraints: const BoxConstraints(minWidth: 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  onSelected: (v) {
                    ref.read(selectedProjectYearProvider.notifier).state = int.parse(v);
                  },
                  itemBuilder: (context) => years.map((year) {
                    final isSelected = year == selectedYear;
                    final cs = Theme.of(context).colorScheme;
                    return PopupMenuItem<String>(
                      value: year.toString(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? Colors.blue.withValues(alpha: 0.12)
                              : Theme.of(context).custom.cardBackground!,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue.withValues(alpha: 0.45)
                                : cs.outline.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              year.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.blue.shade400
                                    : cs.onSurface,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.blue.shade400,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: customColors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 14,
                          color: customColors.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedYear.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: customColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: customColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
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
