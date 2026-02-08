import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class GlobalError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isNetworkError;

  const GlobalError({
    super.key,
    required this.message,
    required this.onRetry,
    this.isNetworkError = false,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 64,
              color: customColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError ? 'No Internet Connection' : 'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: customColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: customColors.primary!,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
