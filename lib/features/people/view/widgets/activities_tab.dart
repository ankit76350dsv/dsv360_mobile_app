import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/models/active_user.dart';
import 'package:dsv360/features/people/view/widgets/info_card.dart';
import 'package:dsv360/features/people/view/widgets/time_logs_card.dart';
import 'package:dsv360/features/people/view/widgets/work_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ActivitiesTab extends ConsumerWidget {
  const ActivitiesTab({super.key});

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else {
      return 'night';
    }
  }

  String _getGreetingTitle(ActiveUserModel? activeUser) {
    final timeOfDay = _getTimeOfDayGreeting();
    return 'Good ${timeOfDay.substring(0, 1).toUpperCase()}${timeOfDay.substring(1)} ${activeUser?.firstName} ${activeUser?.lastName}';
  }

  String _getGreetingSubtitle() {
    final timeOfDay = _getTimeOfDayGreeting();
    return 'Have a productive $timeOfDay!';
  }

  String _getCurrentWeekRange() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    final format = DateFormat('dd MMM yyyy');
    return '${format.format(firstDayOfWeek)} – ${format.format(lastDayOfWeek)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final customColors = Theme.of(context).custom;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InfoCard(
          title: _getGreetingTitle(activeUser),
          subtitle: _getGreetingSubtitle(),
          icon: Icons.person,
          accentColor: Colors.blue,
        ),
        InfoCard(
          title: 'Check-in reminder',
          subtitle: 'Your shift is completed\n9:00 AM – 7:00 PM',
          icon: Icons.alarm,
          accentColor: customColors.primary!,
        ),
        WorkScheduleCard(weekRange: _getCurrentWeekRange()),
        const TimeLogsCard(),
      ],
    );
  }
}
