import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/people/model/attendance_dashboard.dart';
import 'package:dsv360/features/people/repositories/attendance_dashboard_repository.dart';
import 'package:dsv360/features/people/view/widgets/attendance_tile.dart';
import 'package:dsv360/features/people/viewmodel/attendance_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AttendanceTab extends ConsumerStatefulWidget {
  const AttendanceTab({super.key});

  @override
  ConsumerState<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<AttendanceTab> {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final userId = activeUser?.userId ?? '';

    if (userId.isEmpty) {
      return const Center(child: GlobalLoader(message: 'Loading user info...'));
    }

    final selected = ref.watch(attendancePeriodProvider);
    final range = getAttendanceDateRange(selected);
    final startDate = range.$1;
    final endDate = range.$2;
    final formatter = DateFormat('yyyy-MM-dd');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Attendance",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final result = await showMenu<String>(
                    context: context,
                    position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                    items: attendancePeriodOptions
                        .map(
                          (e) =>
                              PopupMenuItem<String>(value: e, child: Text(e)),
                        )
                        .toList(),
                  );
                  if (result != null) {
                    ref.read(attendancePeriodProvider.notifier).state = result;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: customColors.greyBorder!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selected),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<AttendanceDashboardResponse>(
            future: ref
                .read(attendanceDashboardRepositoryProvider)
                .fetchAttendanceDashboard(
                  userId: userId,
                  startDate: formatter.format(startDate),
                  endDate: formatter.format(endDate),
                ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: GlobalLoader(message: 'Fetching attendance...'),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: GlobalError(
                    message: 'Failed to load attendance: Try Again',
                    onRetry: () => setState(() {}),
                  ),
                );
              }

              final response = snapshot.data;
              if (response == null || response.data.isEmpty) {
                return const Center(
                  child: Text('No attendance records found'),
                );
              }

              final presentDates = response.data.map((e) => e.dayDate).toSet();
              final List<Widget> children = [];
              DateTime current = startDate;

              while (current.isBefore(endDate) ||
                  current.isAtSameMomentAs(endDate)) {
                final dateStr = formatter.format(current);
                final isWeekend =
                    current.weekday == DateTime.saturday ||
                    current.weekday == DateTime.sunday;
                final isPresent = presentDates.contains(dateStr);

                String status;
                Color statusColor;
                bool highlight = false;

                if (isWeekend) {
                  status = "Weekend";
                  statusColor = Colors.red;
                  highlight = true;
                } else if (isPresent) {
                  status = "Present";
                  statusColor = Colors.green;
                } else {
                  status = "Absent";
                  statusColor = Colors.red;
                }

                children.add(
                  AttendanceTile(
                    day: DateFormat('EEE').format(current),
                    date: DateFormat('d MMM').format(current),
                    status: status,
                    statusColor: statusColor,
                    highlight: highlight,
                  ),
                );

                current = current.add(const Duration(days: 1));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: children,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
