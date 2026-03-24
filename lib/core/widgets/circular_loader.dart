import 'dart:math' as math;
import 'package:flutter/material.dart';

// Single dot traces a hollow circle clockwise, then retracts — seamless loop.
//  0.00 – 0.65  Dot leads the arc clockwise (draws on)
//  0.65 – 1.00  Tail erases forward toward dot at origin (retracts)

class CircularLoader extends StatefulWidget {
  final double size;

  const CircularLoader({super.key, this.size = 48});

  @override
  State<CircularLoader> createState() => _CircularLoaderState();
}

class _CircularLoaderState extends State<CircularLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _CircleOrbitPainter(t: _controller.value),
        ),
      ),
    );
  }
}

class _CircleOrbitPainter extends CustomPainter {
  final double t;

  static const Color _color = Color.fromARGB(255, 20, 91, 167);

  const _CircleOrbitPainter({required this.t});

  static double _ease(double x) {
    x = x.clamp(0.0, 1.0);
    return x < 0.5 ? 2 * x * x : 1 - math.pow(-2 * x + 2, 2) / 2;
  }

  static double _localT(double t, double s, double e) =>
      ((t - s) / (e - s)).clamp(0.0, 1.0);

  static Offset _circlePoint(Offset c, double r, double frac) {
    final a = -math.pi / 2 + 2 * math.pi * frac.clamp(0.0, 1.0);
    return Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
  }

  static Path _circlePath(Offset c, double r, double frac) {
    frac = frac.clamp(0.0, 1.0);
    if (frac <= 0) return Path();
    return Path()
      ..addArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * frac,
      );
  }

  // Tail-erase: arc from tailFrac → 1.0 (head/dot stays fixed at origin).
  static Path _circlePathTail(Offset c, double r, double tailFrac) {
    tailFrac = tailFrac.clamp(0.0, 1.0);
    final sweep = (1.0 - tailFrac) * 2 * math.pi;
    if (sweep <= 0) return Path();
    return Path()
      ..addArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2 + tailFrac * 2 * math.pi,
        sweep,
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.width * 0.09;
    final dotR = sw * 0.65;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - sw;

    final strokePaint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = _color
      ..style = PaintingStyle.fill;

    final origin = Offset(c.dx, c.dy - r); // 12 o'clock

    if (t < 0.65) {
      // Draw on: dot leads clockwise.
      final frac = _ease(_localT(t, 0.0, 0.65));
      if (frac > 0.005) canvas.drawPath(_circlePath(c, r, frac), strokePaint);
      canvas.drawCircle(_circlePoint(c, r, frac), dotR, dotPaint);
    } else {
      // Retract: dot stays at origin, tail erases forward.
      final tailFrac = _ease(_localT(t, 0.65, 1.0));
      if (tailFrac < 0.995) {
        canvas.drawPath(_circlePathTail(c, r, tailFrac), strokePaint);
      }
      canvas.drawCircle(origin, dotR, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_CircleOrbitPainter old) => old.t != t;
}
