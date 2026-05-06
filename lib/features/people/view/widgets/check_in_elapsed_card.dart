import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/people/view/widgets/time_box.dart';
import 'package:flutter/material.dart';

class CheckInElapsedCard extends StatelessWidget {
  final Duration elapsed;
  final bool isCheckedIn;

  const CheckInElapsedCard({
    super.key,
    required this.elapsed,
    required this.isCheckedIn,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: customColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'TIME ELAPSED',
                  style: TextStyle(
                    color: customColors.textSecondary,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TimeBox(value: elapsed.inDays, label: "Days"),
                TimeBox(value: elapsed.inHours % 24, label: "Hrs"),
                TimeBox(value: elapsed.inMinutes % 60, label: "Mins"),
                TimeBox(value: elapsed.inSeconds % 60, label: "Secs"),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isCheckedIn
                    ? customColors.primary!.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: isCheckedIn ? customColors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCheckedIn ? 'Checked In' : 'Not Checked In',
                    style: TextStyle(
                      color: isCheckedIn ? customColors.primary : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
