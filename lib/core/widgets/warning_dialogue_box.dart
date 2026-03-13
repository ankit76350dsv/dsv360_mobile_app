import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

Future<T?> showWarningDialogueBox<T>({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String primaryText,
  void Function(BuildContext dialogContext)? onPrimaryPressed,
}) {
  return showDialog<T>(
    context: context,
    builder: (_) => WarningDialogueBox(
      title: title,
      subtitle: subtitle,
      primaryText: primaryText,
      onPrimaryPressed: onPrimaryPressed,
    ),
  );
}

class WarningDialogueBox extends StatelessWidget {
  const WarningDialogueBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryText,
    this.onPrimaryPressed,
  });

  final String title;
  final String subtitle;
  final String primaryText;
  final void Function(BuildContext dialogContext)? onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    final dc = Theme.of(context).custom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: dc.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: dc.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: dc.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dc.textPrimary,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (onPrimaryPressed != null) {
                        onPrimaryPressed!(context);
                        return;
                      }
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dc.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                    ),
                    child: Text(
                      primaryText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
