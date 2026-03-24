import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/circular_loader.dart';
import 'package:dsv360/models/dashboard_model.dart';
import 'package:dsv360/providers/dashboard_provider.dart'; // for selectedYearProvider
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerWidget + WidgetRef

// Changed StatelessWidget → ConsumerWidget so we can read/write selectedYearProvider.
class TaskStatusCard extends ConsumerWidget {
  // No taskData param — the card fetches its own data via taskStatusDataProvider.
  const TaskStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height * 0.28;
    final customColors = Theme.of(context).custom;

    // Read the currently selected year.
    final selectedYear = ref.watch(selectedYearProvider);

    // Build selectable year list: current year + 2 years back (e.g. 2026, 2025 … 2022).
    final currentYear = DateTime.now().year;
    final years = List.generate(2, (i) => currentYear - i);

    // Watch the task-specific provider — only this card rebuilds when year changes.
    final taskAsync = ref.watch(taskStatusDataProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: customColors.inputFill,
                child: Icon(Icons.schedule, color: customColors.textPrimary),
              ),
              title: Text(
                'Task Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: customColors.textPrimary,
                ),
              ),
             

              // Premium year picker: trigger shows selected year, only the inner
              // container highlights on hover/tap — not the whole menu row.
              trailing: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: PopupMenuButton<String>(
                  
                  color: customColors.cardBackground,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.10),
                  offset: const Offset(0, 8),
                  constraints: const BoxConstraints(minWidth: 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  // onSelected updates the provider — drives taskStatusDataProvider rebuild.
                  onSelected: (v) {
                    ref.read(selectedYearProvider.notifier).state = int.parse(v);
                  },
                  itemBuilder: (context) => years.map((year) {
                    final isSelected = year == selectedYear;
                    // cs from itemBuilder context so dark/light is respected inside the menu.
                    final cs = Theme.of(context).colorScheme;
                    return PopupMenuItem<String>(
                      value: year.toString(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      // AnimatedContainer handles the selected-state highlight;
                      // outer row ripple is suppressed via Theme above.
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
                                : cs.outline.withValues(alpha: 0),
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
                                // onSurface works in both light and dark
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
                  // Custom trigger: pill showing filter icon + selected year + chevron.
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
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height, minHeight: 140),
              // when() renders loader/error/data inline — page is never touched.
              child: taskAsync.when(
                skipLoadingOnRefresh: false,
                data: (taskData) => TaskStatusContent(taskData: taskData),
                loading: () => const Center(child: CircularLoader()),
                error: (e, _) => const Center(child: Text('Failed to load')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskStatusContent extends StatelessWidget {
  final YearTaskData taskData;

  const TaskStatusContent({super.key, required this.taskData});

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).custom;

    // taskData is YearTaskData, passed from dashboard_page.dart via:
    //   TaskStatusCard(taskData: dashboard.yearTaskData)
    // where `dashboard` is a DashboardModel fetched by DashboardRepository
    //   → API: GET .../time_entry_management_application_function/mobile/dashboard
    //   → parsed in DashboardModel.fromJson → json['yearTaskData']
    //   → then YearTaskData.fromJson → keys: 'open', 'in_progress', 'closed'
    final total = taskData.open + taskData.inProgress + taskData.closed;

    debugPrint(
      '📊 TaskStatusCard — open: ${taskData.open}, inProgress: ${taskData.inProgress}, closed: ${taskData.closed}, total: $total',
    );

    // Avoid division by zero
    final openPct = total == 0 ? 0.0 : (taskData.open / total) * 100;
    final inProgressPct = total == 0
        ? 0.0
        : (taskData.inProgress / total) * 100;
    final closedPct = total == 0 ? 0.0 : (taskData.closed / total) * 100;

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 30,
              sections: [
                PieChartSectionData(
                  color: custom.statusCompleted,
                  value: closedPct,
                  title: '${closedPct.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: custom.statusInProgress,
                  value: openPct,
                  title: '${openPct.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: custom.error,
                  value: inProgressPct,
                  title: '${inProgressPct.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendDot(
              color: custom.statusCompleted!,
              label: 'Completed (${taskData.closed})',
            ),
            const SizedBox(height: 8),
            _LegendDot(
              color: custom.statusInProgress!,
              label: 'Open (${taskData.open})',
            ),
            const SizedBox(height: 8),
            _LegendDot(
              color: custom.error!,
              label: 'In Progress (${taskData.inProgress})',
            ),
          ],
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
    final theme = Theme.of(context);
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
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
