import 'dart:math';
import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

/// Horizontal morphing velocity loader.
///
/// Sequence (loops):
///   dot appears at left
///   → stretches right into a pill line
///   → expands vertically into a rounded rectangle  (animated gradient)
///   → collapses into a circle
///   → shrinks to dot at center
///   → dot slides back left
///   → dot fades out → restart
class VelocityMorphLoader extends StatefulWidget {
  final Color? color;

  const VelocityMorphLoader({super.key, this.color});

  @override
  State<VelocityMorphLoader> createState() => _VelocityMorphLoaderState();
}

class _VelocityMorphLoaderState extends State<VelocityMorphLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the exact dark blue from CustomColors.primary (seed 0xFF004da7)
    final color = widget.color ??
        Theme.of(context).custom.primary ??
        const Color.fromARGB(255, 0, 98, 235);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        size: const Size(220, 48),
        painter: _MorphPainter(progress: _controller.value, color: color),
      ),
    );
  }
}

class _MorphPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MorphPainter({required this.progress, required this.color});

  // Clamp t into [0,1] within segment [from, to]
  static double _seg(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

  // Smooth-step: easeInOut cubic
  static double _smooth(double t) => t * t * (3.0 - 2.0 * t);

  // Ease-out cubic — fast start, gentle settle
  static double _easeOut(double t) {
    final u = 1.0 - t;
    return 1.0 - u * u * u;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    final cy = H / 2.0;
    final t = progress;

    // ── Dimension constants ──────────────────────────────────────────────────
    final pad = W * 0.045;
    final dotD = H * 0.28;        // dot diameter      ≈ 13 px @ H=48
    final lineH = H * 0.17;       // line (pill) height ≈ 8 px
    final rectH = H * 0.82;       // rectangle height   ≈ 39 px
    final rectW = W * 0.52;       // rectangle width    ≈ 114 px @ W=220
    final circleD = rectH;        // circle diameter = rectH → perfect circle

    // ── Anchor X positions ───────────────────────────────────────────────────
    final dotLeft = pad;
    final dotCenter = (W - dotD) / 2.0;
    final rectLeft = (W - rectW) / 2.0;
    final circleLeft = (W - circleD) / 2.0;

    // ── Per-frame shape values ───────────────────────────────────────────────
    double left, w, h, r, opacity;

    // Phase 2 (0.00 – 0.40): dot at left stretches right → pill line
    //   dot is already visible from Phase 6 end, so no pop-in needed
    //   width races to full-width in first 16%; height collapses in first 6%
    if (t <= 0.40) {
      opacity = 1.0;
      final wProg = _smooth(_seg(t, 0.00, 0.16)); // 2× faster
      final hProg = _easeOut(_seg(t, 0.00, 0.06)); // proportionally faster
      left = dotLeft;
      w = _lerp(dotD, W - 2.0 * pad, wProg);
      h = _lerp(dotD, lineH, hProg);
      r = h / 2.0;        // always pill-rounded

    // Phase 3 (0.40 – 0.60): pill line → centred rounded rectangle
    //   line contracts to rectW while spreading taller; centering simultaneously
    } else if (t <= 0.60) {
      opacity = 1.0;
      final p = _smooth(_seg(t, 0.40, 0.60));
      left = _lerp(dotLeft, rectLeft, p);
      w = _lerp(W - 2.0 * pad, rectW, p);
      h = _lerp(lineH, rectH, p);
      r = _lerp(lineH / 2.0, 14.0, p);

    // Phase 4 (0.60 – 0.72): rectangle → circle
    //   width contracts to match circleD, corner radius rises to full
    } else if (t <= 0.72) {
      opacity = 1.0;
      final p = _smooth(_seg(t, 0.60, 0.72));
      left = _lerp(rectLeft, circleLeft, p);
      w = _lerp(rectW, circleD, p);
      h = _lerp(rectH, circleD, p);
      r = _lerp(14.0, circleD / 2.0, p);

    // Phase 5 (0.72 – 0.82): circle shrinks to a dot at centre
    } else if (t <= 0.82) {
      opacity = 1.0;
      final p = _smooth(_seg(t, 0.72, 0.82));
      left = _lerp(circleLeft, dotCenter, p);
      w = _lerp(circleD, dotD, p);
      h = _lerp(circleD, dotD, p);
      r = w / 2.0;

    // Phase 6 (0.82 – 1.00): dot accelerates left and holds — no fade
    } else {
      opacity = 1.0;
      final p = _smooth(_seg(t, 0.82, 1.00));
      left = _lerp(dotCenter, dotLeft, p);
      w = dotD;
      h = dotD;
      r = dotD / 2.0;
    }

    final shapeRect = Rect.fromLTWH(left, cy - h / 2.0, w, h);

    // Guard: skip degenerate geometry at loop boundary (opacity=0 or sub-pixel shapes)
    if (w < 1.0 || h < 1.0 || opacity < 0.01) return;

    // ── DSV text opacity: visible only when shape is clearly rectangular ─────
    // Fades in as rectangle finishes forming, fades out as it becomes a circle.
    // Text is sized to the CURRENT shape (w, h) so it morphs naturally with it.
    double textOpacity = 0.0;
    double textScale = 1.0;
    if (t > 0.55 && t < 0.73) {
      if (t <= 0.61) {
        textOpacity = _smooth(_seg(t, 0.55, 0.61));
      } else {
        textOpacity = 1.0;
      }
      textOpacity *= opacity;
      // Scale down instead of fade during rectangle → circle collapse
      if (t > 0.68) {
        textScale = 1.0 - _smooth(_seg(t, 0.68, 0.73));
      }
    }

    // ── Animated gradient ────────────────────────────────────────────────────
    // `shimmer` oscillates 0→1→0→1 twice per loop (2 cycles via sin)
    // This pulses the gradient between lighter and darker shades of `color`
    final shimmer = sin(t * pi * 4.0) * 0.5 + 0.5;

    final cLighter = _shiftLightness(color, 0.32 * shimmer);
    final cLight = _shiftLightness(color, 0.14 * shimmer);
    final cBase = color;
    final cDark = _shiftLightness(color, -0.16 * shimmer);

    // Apply frame opacity directly to each color (avoids saveLayer overhead)
    Color withOp(Color c) => opacity >= 0.999
        ? c
        : Color.fromARGB(
            (c.alpha * opacity).round(), c.red, c.green, c.blue);

    // Gradient rect wider than shape so the shading looks soft even on tiny shapes
    final gradRect = shapeRect.inflate(w * 0.35 + 6.0);

    final shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        withOp(cLighter),
        withOp(cLight),
        withOp(cBase),
        withOp(cDark),
        withOp(cLight),
        withOp(cLighter),
      ],
      stops: const [0.0, 0.15, 0.38, 0.62, 0.85, 1.0],
    ).createShader(gradRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(shapeRect, Radius.circular(r)),
      Paint()..shader = shader,
    );

    if (textOpacity > 0.01 && textScale > 0.01) {
      _drawDSV(canvas, shapeRect.center, w, h, textOpacity, textScale);
    }
  }

  /// Draws "DSV" centred inside the shape with equal padding on all four edges.
  ///
  /// Equal-padding formula:
  ///   p = (rH - textH) / 2      (vertical constraint sets the padding)
  ///   targetTextW = rW - 2*p    (horizontal constraint must match)
  ///   letterSpacing = (targetTextW - naturalTextW) / charCount
  /// This stretches "D   S   V" horizontally to fill the shape symmetrically.
  void _drawDSV(Canvas canvas, Offset center, double rW, double rH, double alpha, [double textScale = 1.0]) {
    const text = 'DSV';

    // ── Step 1: measure natural dimensions at a reference font size ──────────
    final ref = TextPainter(
      text: const TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // ── Step 2: scale font so text height fills 50% of the shape height (more padding) ──────
    final scale = (rH * 0.50) / ref.height;
    final fontSize = 100.0 * scale;
    final scaledH = ref.height * scale;
    final scaledWnatural = ref.width * scale;

    // ── Step 3: derive equal padding and required text width ─────────────────
    final p = (rH - scaledH) / 2.0; // equal vertical padding
    final targetW = rW - 2.0 * p;   // matching horizontal constraint

    // Distribute any extra width as letter spacing across all characters
    final extraPerChar = max(0.0, (targetW - scaledWnatural) / text.length);

    // ── Step 4: paint ────────────────────────────────────────────────────────
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: extraPerChar,
          color: Colors.white.withValues(alpha: alpha),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(textScale, textScale);
    canvas.translate(-center.dx, -center.dy);
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2.0, center.dy - painter.height / 2.0),
    );
    canvas.restore();
  }

  Color _shiftLightness(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + delta).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(_MorphPainter old) => old.progress != progress;
}
