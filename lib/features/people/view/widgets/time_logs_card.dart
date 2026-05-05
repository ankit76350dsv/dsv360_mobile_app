import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/people/model/attendance_detail.dart';
import 'package:dsv360/features/people/repositories/time_logs_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TimeLogsCard extends ConsumerWidget {
  const TimeLogsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final userId = activeUser?.userId ?? '';

    if (userId.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final timeLogsAsync = ref.watch(
      timeLogsRepositoryProvider(
        userId: userId,
        startDate: todayStr,
        endDate: todayStr,
      ),
    );

    return timeLogsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Something went wrong. Please try again.',
          style: TextStyle(color: Colors.red),
        ),
      ),
      data: (timeLogs) => _TimeLogsContent(timeLogs: timeLogs),
    );
  }
}

class _TimeLogsContent extends StatelessWidget {
  final List<AttendanceDetail> timeLogs;

  const _TimeLogsContent({required this.timeLogs});

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--:--';
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  String _formatTotalTime(String? totalTime) {
    if (totalTime == null || totalTime.isEmpty) return '0 m';
    try {
      final minutes = int.tryParse(totalTime) ?? 0;
      return '$minutes m';
    } catch (e) {
      return '0 m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: customColors.primary!, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Today's Time Logs",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: customColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: customColors.greyBorder!),
                ),
              ),
              child: Row(
                children: const [
                  _HeaderCell('Check-In'),
                  _HeaderCell('Check-Out'),
                  _HeaderCell('Total Time', alignRight: true),
                ],
              ),
            ),
            if (timeLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No check-in/check-out logs found',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: customColors.textSecondary,
                  ),
                ),
              )
            else
              ...timeLogs.map(
                (log) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: customColors.greyBorder!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatTime(log.checkIn),
                          style: TextStyle(
                            color: customColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          log.checkOut != null
                              ? _formatTime(log.checkOut)
                              : '--:--:--',
                          style: TextStyle(
                            color: log.checkOut != null
                                ? customColors.error
                                : customColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatTotalTime(log.totalTime),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: customColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final bool alignRight;

  const _HeaderCell(this.text, {this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Expanded(
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: customColors.textPrimary,
        ),
      ),
    );
  }
}
