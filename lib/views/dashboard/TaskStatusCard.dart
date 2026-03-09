import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/dashboard_model.dart';
import 'package:dsv360/providers/dashboard_provider.dart'; // for selectedYearProvider
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerWidget + WidgetRef
import '../widgets/custom_popup_dropdown.dart';

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
              // CustomPopupDropdown replaces the old PopupMenuButton — same year logic, new themed UI.
              trailing: SizedBox(
                width: 110,
                child: CustomPopupDropdown(
                  value: selectedYear.toString(),
                  hint: 'Year',
                  items: years.map((y) => y.toString()).toList(),
                  icon: Icons.calendar_today,
                  iconSize: 18,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(selectedYearProvider.notifier).state = int.parse(v);
                    }
                  },
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height, minHeight: 140),
              // when() renders loader/error/data inline — page is never touched.
              child: taskAsync.when(
                data: (taskData) => TaskStatusContent(taskData: taskData),
                loading: () => const Center(child: CircularProgressIndicator()),
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

    debugPrint('📊 TaskStatusCard — open: ${taskData.open}, inProgress: ${taskData.inProgress}, closed: ${taskData.closed}, total: $total');
  
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
