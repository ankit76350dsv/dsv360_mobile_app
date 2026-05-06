import 'package:flutter/material.dart';

class WaveLoader extends StatelessWidget {
  final int dotCount;
  final double dotSize;
  final double dotGap;
  final List<Animation<double>> dotScales;
  final Color color;

  const WaveLoader({
    super.key,
    required this.dotCount,
    required this.dotScales,
    required this.color,
    this.dotSize = 6.0,
    this.dotGap = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dotCount * dotSize + (dotCount - 1) * dotGap,
      height: dotSize * 1.4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(dotCount, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < dotCount - 1 ? dotGap : 0),
            child: AnimatedBuilder(
              animation: dotScales[i],
              builder: (_, __) => Transform.scale(
                scale: dotScales[i].value,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
