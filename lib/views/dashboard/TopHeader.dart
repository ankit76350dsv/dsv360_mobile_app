import 'package:flutter/material.dart';
import 'package:dsv360/core/constants/app_colors.dart';

class TopHeader extends StatelessWidget {
  final bool isLarge;
  final int projectCnt;
  final int completedProjectCnt;
  final int taskCnt;
  final int taskClosedCnt;
  final int issueCnt;

  const TopHeader({
    required this.isLarge,
    required this.projectCnt,
    required this.completedProjectCnt,
    required this.taskCnt,
    required this.taskClosedCnt,
    required this.issueCnt,
  });

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

    final projectPct = projectCnt == 0 ? 0 : (completedProjectCnt / projectCnt * 100).toInt();
    final taskPct = taskCnt == 0 ? 0 : (taskClosedCnt / taskCnt * 100).toInt();
    
    // Issue handling: we only have 'issueCnt' from API. 
    // Assuming issueCnt is Total. We don't have 'Resolved' count from the provided JSON.
    // I'll reuse 'issueCnt' as Total and maybe '0' as resolved, or hide percentage?
    // Current design shows '0 of 4' etc and a percentage.
    // I'll show 'Total' vs 'N/A' or just 0%.
    // To match design 'Issue Resolved' label:
    // I'll put issueCnt as denominator? '0 of X'.
    final issuePct = 0; 

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
            percentText: '$projectPct%',
            smallLabel: '$completedProjectCnt of $projectCnt',
            label: 'Project Closed',
            scale: scale,
          ),
          _RightMetric(
            percentText: '$taskPct%',
            smallLabel: '$taskClosedCnt of $taskCnt',
            label: 'Tasks Completed',
            scale: scale,
          ),
          _RightMetric(
            percentText: '$issueCnt',
            smallLabel: 'Total',
            label: 'Issues', // Changed label to match available data
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



