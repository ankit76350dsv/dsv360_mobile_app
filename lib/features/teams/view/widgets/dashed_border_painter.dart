import 'dart:math';
import 'package:flutter/material.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║               DASHED BORDER PAINTER                         ║
// ╚══════════════════════════════════════════════════════════════╝

class DashedBorderPainter extends CustomPainter {
  final Color color;

  const DashedBorderPainter({
    this.color = const Color(0xFFCCCCCC),
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.5;
    const dashWidth = 7.0;
    const dashGap = 5.0;
    const radius = 12.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
            size.width - strokeWidth, size.height - strokeWidth),
        Radius.circular(radius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)?.position;
        final end = metric
            .getTangentForOffset(min(distance + dashWidth, metric.length))
            ?.position;
        if (start != null && end != null) {
          canvas.drawLine(start, end, paint);
        }
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
