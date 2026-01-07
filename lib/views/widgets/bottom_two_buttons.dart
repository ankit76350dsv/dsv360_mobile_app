import 'package:flutter/material.dart';

class BottomTwoButtons extends StatelessWidget {
  final String button1Text;
  final String button2Text;
  final VoidCallback button1Function;
  final VoidCallback? button2Function;

  const BottomTwoButtons({
    super.key,
    required this.button1Text,
    required this.button2Text,
    required this.button1Function,
    this.button2Function,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: button1Function,
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              button1Text.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: button2Function,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              button2Text.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
