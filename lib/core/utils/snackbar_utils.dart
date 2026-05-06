import 'package:flutter/material.dart';

/// Show a snackbar and dismiss any previously queued snackbars
/// This ensures only the most recent snackbar is displayed
void showSnackBar(BuildContext context, SnackBar snackbar) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

/// Helper to show error snackbar
void showErrorSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  showSnackBar(
    context,
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.red,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ),
  );
}

/// Helper to show success snackbar
void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  showSnackBar(
    context,
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: const Color(0xFF4CAF50),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ),
  );
}

//how to use snackbar utils? here.
// showErrorSnackBar(context, 'Your message'); for error

// showSuccessSnackBar(context, 'Success message'); for success


// showSnackBar(context, SnackBar(...)); for custom