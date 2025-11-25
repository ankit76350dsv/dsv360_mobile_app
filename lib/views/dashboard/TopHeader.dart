import 'package:flutter/material.dart';

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

    final height = (isLarge ? 140.0 : 180.0) * 0.5;
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
        children: [
          // left icon
          Container(
            width: 56 * scale,
            height: 56 * scale,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Icon(Icons.dashboard, size: 28 * scale, color: Colors.white),
          ),

          SizedBox(width: 14 * scale),

          // title + subtitle (takes available space but won't overlap metrics)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  'November 13, 2025',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // vertical metrics column on the right
          SizedBox(width: 12 * scale),
          SizedBox(
            width: rightColumnWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RightMetric(
                  percentText: '0%',
                  smallLabel: '0 of 1',
                  scale: scale,
                ),
                _RightMetric(
                  percentText: '0%',
                  smallLabel: '0 of 4',
                  scale: scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RightMetric extends StatelessWidget {
  final String percentText;
  final String smallLabel;
  final double scale;

  const _RightMetric({
    required this.percentText,
    required this.smallLabel,
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
                color: Colors.white24,
                backgroundColor: Colors.white12,
              ),
              Text(
                percentText,
                style: TextStyle(
                  color: Colors.white,
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
          style: TextStyle(color: Colors.white70, fontSize: 11 * scale),
        ),
      ],
    );
  }
}



