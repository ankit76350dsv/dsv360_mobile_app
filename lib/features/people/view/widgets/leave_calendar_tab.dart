import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/people/repositories/leaves_repository.dart';
import 'package:dsv360/features/people/view/widgets/legend_chip.dart';
import 'package:dsv360/features/people/viewmodel/leave_calendar_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LeaveCalendarTab extends ConsumerStatefulWidget {
  const LeaveCalendarTab({super.key});

  @override
  ConsumerState<LeaveCalendarTab> createState() => _LeaveCalendarTabState();
}

class _LeaveCalendarTabState extends ConsumerState<LeaveCalendarTab> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final leadDays = firstDayOfMonth.weekday % 7;

    final connectivityStatus = ref.watch(checkConnectivityProvider);
    final calendarAsync = ref.watch(leaveCalendarRepositoryProvider);
    final calendarVM = ref.watch(leaveCalendarViewModelProvider);

    return connectivityStatus.when(
      data: (results) {
        if (results.contains(ConnectivityResult.none)) {
          return GlobalError(
            message: 'Please check your internet connection.',
            isNetworkError: true,
            onRetry: () {
              ref.invalidate(checkConnectivityProvider);
            },
          );
        }

        return calendarAsync.when(
          data: (calendarEvents) {
            final mappedLeaves =
                buildMonthLeaveMap(calendarEvents, year, month);
            final theme = Theme.of(context);

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(leaveCalendarRepositoryProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave Calendar',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(now),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8,
                    children: [
                      LegendChip('Sick Leave', const Color(0xFFFACC15)),
                      LegendChip('Paid Leave', const Color(0xFF2DD4BF)),
                      LegendChip('Unpaid Leave', const Color(0xFFF87171)),
                      LegendChip('Others', const Color(0xFF94A3B8)),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: daysInMonth + leadDays,
                    itemBuilder: (context, index) {
                      if (index < leadDays) {
                        return const SizedBox();
                      }
                      final day = index - leadDays + 1;
                      final leaves = mappedLeaves[day] ?? [];
                      final isToday = day == now.day &&
                          month == now.month &&
                          year == now.year;
                      final isSelected = calendarVM.selectedDay == day;

                      return InkWell(
                        onTap: () {
                          ref
                              .read(leaveCalendarViewModelProvider.notifier)
                              .selectDay(day, leaves);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  )
                                : isToday
                                ? Border.all(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.5),
                                    width: 1.5,
                                  )
                                : Border.all(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.1),
                                  ),
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.05)
                                : null,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$day',
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isToday
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (leaves.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.05),
                                      ),
                                      child: Text(
                                        '${leaves.length}',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (isToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1D4ED8)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'T',
                                    style: TextStyle(
                                      color: Color(0xFF3B82F6),
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              if (leaves.isEmpty && !isToday)
                                Text(
                                  'No leaves',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.4),
                                    fontSize: 7,
                                  ),
                                )
                              else ...[
                                Wrap(
                                  spacing: 3,
                                  runSpacing: 3,
                                  children: leaves
                                      .map((l) => _CalendarDot(
                                          getLeaveColor(l.leaveType)))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  if (calendarVM.selectedDay != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Leaves on day ${calendarVM.selectedDay}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (calendarVM.selectedLeaves == null ||
                              calendarVM.selectedLeaves!.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.05),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 40,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.2),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No leaves scheduled for this day',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.5),
                                        ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: calendarVM.selectedLeaves!.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final leaf =
                                    calendarVM.selectedLeaves![index];
                                final color =
                                    getLeaveColor(leaf.leaveType);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.05),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: color,
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      leaf.username,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    subtitle: Padding(
                                      padding:
                                          const EdgeInsets.only(top: 4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            leaf.leaveType
                                                .replaceAll('_', ' '),
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${leaf.startDate} to ${leaf.endDate}',
                                            style:
                                                theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Click on any day to see details',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.touch_app_outlined,
                              size: 48,
                              color: theme.colorScheme.primary.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select a day to view leaves',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(
              child: GlobalLoader(message: 'Loading calendar...')),
          error: (err, stack) => Center(
            child: GlobalError(
              message: 'Failed to load calendar: Try Again',
              onRetry: () => ref.refresh(leaveCalendarRepositoryProvider),
            ),
          ),
        );
      },
      loading: () => const GlobalLoader(message: 'Checking connection...'),
      error: (err, stack) => Center(
        child: GlobalError(
          message: 'Failed to check connectivity: Try Again',
          onRetry: () => ref.invalidate(checkConnectivityProvider),
        ),
      ),
    );
  }
}

class _CalendarDot extends StatelessWidget {
  final Color color;
  const _CalendarDot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
