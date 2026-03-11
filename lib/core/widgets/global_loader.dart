

import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/widgets/loader.dart';
import 'package:flutter/material.dart';

class GlobalLoader extends StatelessWidget {
  final String? message;

  const GlobalLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //CircularProgressIndicator(color: customColors.primary),
          
          VelocityMorphLoader(color: customColors.primary ?? Theme.of(context).colorScheme.primary),

          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: customColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
