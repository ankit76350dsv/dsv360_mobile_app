import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/app_colors.dart';

class TopHeader extends StatelessWidget {
  final bool isLarge;
  const TopHeader({required this.isLarge});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    // scale factor for fonts / paddings
    final scale = w < 360
        ? 0.82
        : w < 480
        ? 0.92
        : w < 600
        ? 1.0
        : 1.15;

    final height = (isLarge ? 140.0 : 180.0) * 0.55;
    // reserve a fixed width on the right for stacked metrics
    final rightColumnWidth = (w * 0.22).clamp(96.0, 140.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1160A6), Color(0xFF0D4A90)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 12 * scale,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RightMetric(
            percentText: '55%',
            smallLabel: '0 of 1',
            label: 'Project Closed',
            scale: scale,
          ),
          _RightMetric(
            percentText: '0%',
            smallLabel: '0 of 1',
            label: 'Tasks Completed',
            scale: scale,
          ),
          _RightMetric(
            percentText: '0%',
            smallLabel: '0 of 4',
            label: 'Issue Resolved',
            scale: scale,
          ),
        ],
      ),
    );
  }
}

class _RightMetric extends StatelessWidget {
  final String percentText;
  final String smallLabel;
  final String label;
  final double scale;

  const _RightMetric({
    required this.percentText,
    required this.smallLabel,
    required this.label,
    required this.scale
  });

  @override
  Widget build(BuildContext context) {
    final double dialSize = 44 * scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: dialSize,
          height: dialSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 0.0,
                strokeWidth: 5 * scale,
                color: AppColors.textWhite.withOpacity(0.24), // Colors.white24
                backgroundColor: AppColors.textWhite.withOpacity(0.12), // Colors.white12
              ),
              Text(
                percentText,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          smallLabel,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 11 * scale),
        ),
        SizedBox(height: 2 * scale),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 10 * scale,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}



