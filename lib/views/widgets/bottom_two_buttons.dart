import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final submitLoadingProvider = StateProvider.family<bool, String>((ref, key) => false);

class BottomTwoButtons extends ConsumerWidget {
  final String loadingKey; 
  final String button1Text;
  final String button2Text;
  final VoidCallback button1Function;
  final VoidCallback? button2Function;

  const BottomTwoButtons({
    super.key,
    required this.loadingKey,
    required this.button1Text,
    required this.button2Text,
    required this.button1Function,
    this.button2Function,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isLoading = ref.watch(submitLoadingProvider(loadingKey));

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: button1Function,
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(
                color: colors.error,
                width: 2.0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(200.0),
              ),
            ),
            child: Text(
              button1Text.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? (){} : button2Function,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(200.0),
                side: BorderSide(
                  width: 2.0,
                  color: colors.primary
                )
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
              button2Text.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
