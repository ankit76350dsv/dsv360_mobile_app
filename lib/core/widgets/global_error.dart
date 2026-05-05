import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class GlobalError extends StatefulWidget {
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
  State<GlobalError> createState() => _GlobalErrorState();
}

class _GlobalErrorState extends State<GlobalError> {
  bool _isRetrying = false;

  void _handleRetry() {
    setState(() => _isRetrying = true);
    widget.onRetry();
    // Spinner stays until the parent replaces this widget on success.
    // didUpdateWidget resets it if the error state is refreshed.
  }

  @override
  void didUpdateWidget(GlobalError oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent re-rendered with a new error (retry failed) — show button again.
    if (_isRetrying) {
      setState(() => _isRetrying = false);
    }
  }

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
              widget.isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 64,
              color: customColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isNetworkError ? 'No Internet Connection' : 'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.message,
              style: TextStyle(
                fontSize: 14,
                color: customColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _isRetrying
                ? CircularProgressIndicator(
                    color: customColors.primary,
                    strokeWidth: 2.5,
                  )
                : ElevatedButton(
                    onPressed: _handleRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColors.primary!,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
          ],
        ),
      ),
    );
  }
}
