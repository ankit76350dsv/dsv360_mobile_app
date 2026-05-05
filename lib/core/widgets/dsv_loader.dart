import 'dart:math';
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
class DsvLoader extends StatefulWidget {
  final Color? color;
  final String label;

  const DsvLoader({super.key, this.color, this.label = 'DSV360'});

  @override
  State<DsvLoader> createState() => _DsvLoaderState();
}

class _DsvLoaderState extends State<DsvLoader>
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
    final color =
        //original color// const Color.fromARGB(255, 0, 87, 164);
        const Color.fromARGB(255, 20, 91, 167);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        size: const Size(220, 64),
        painter: _MorphPainter(
          progress: _controller.value,
          color: color,
          label: widget.label,
        ),
      ),
    );
  }
}

class _MorphPainter extends CustomPainter {
  final double progress;
  final Color color;
  final String label;

  _MorphPainter({
    required this.progress,
    required this.color,
    required this.label,
  });

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
    final dotD = H * 0.28; // dot diameter      ≈ 18 px @ H=64
    final lineH = H * 0.17; // line (pill) height ≈ 11 px
    final progressBarH = H * 0.16; // slightly thicker progress-bar height
    // baseRectH tracks canvas proportion; _kExtraPadding expands the rect on all sides
    final baseRectH = H * 0.60; // core rect height   ≈ 38 px @ H=64
    final rectH = baseRectH + 2.0 * _kExtraPadding;
    // Measure text to derive responsive rectangle width
    final rectW = _computeRectWidth(label, rectH, W - 2.0 * pad);
    final circleD = rectH; // circle diameter = rectH → perfect circle

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
      h = _lerp(dotD, progressBarH, hProg);
      r = h / 2.0; // always pill-rounded

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

    canvas.drawRRect(
      RRect.fromRectAndRadius(shapeRect, Radius.circular(r)),
      Paint()..color = color,
    );

    if (textOpacity > 0.01 && textScale > 0.01) {
      _drawDSV(canvas, shapeRect.center, w, h, textOpacity, textScale);
    }
  }

  /// Measures [text] at the same font size used in [_drawDSV] and returns
  /// the rectangle width so that all four edges have equal padding.
  ///
  /// ── HOW TO ADJUST PADDING ─────────────────────────────────────────────
  /// Two independent knobs. Change either and the rectangle resizes while the
  /// text stays the same size (or vice-versa).
  ///
  ///   [_kExtraPadding]  — extra pixels added on EACH of the four sides,
  ///                       on top of the natural equal-padding from the text.
  ///     ↑ increase → bigger rectangle (wider & taller), text UNCHANGED
  ///     ↓ decrease → smaller rectangle, text UNCHANGED
  ///     e.g.   0.0 → no extra space (rect is snug around text)
  ///            6.0 → current (~6 px extra per side)
  ///           12.0 → roomy
  ///
  ///   [_kTextFillRatio] — fraction of the INNER rect height (rect minus
  ///                       extra padding) that the text height fills.
  ///     ↑ increase → larger text, less natural padding
  ///     ↓ decrease → smaller text, more natural padding
  ///     0.50 = original size (current)
  ///
  /// Tip: only want more padding?  →  raise [_kExtraPadding]
  ///      only want bigger text?    →  raise [_kTextFillRatio]
  static const double _kExtraPadding = 6.0; // ← extra px per side  (rect grows)
  static const double _kTextFillRatio =
      0.50; // ← text fill ratio    (0.50 = original size)
  double _computeRectWidth(String text, double rectH, double maxW) {
    final ref = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Text is sized against inner height (rect minus extra padding on both sides),
    // so text stays the same absolute size even when _kExtraPadding changes.
    final innerH = rectH - 2.0 * _kExtraPadding;
    final scale = (innerH * _kTextFillRatio) / ref.height;
    final scaledW = ref.width * scale;
    // p = equal padding on each edge = (rectH - textH) / 2
    // This automatically includes _kExtraPadding since rectH is already expanded.
    final p = (rectH - ref.height * scale) / 2.0;
    // clamp: at minimum a square (rectH), at maximum the canvas width minus margins
    return (scaledW + 2.0 * p).clamp(rectH, maxW);
  }

  /// Draws "DSV" centred inside the shape with equal padding on all four edges.
  ///
  /// Equal-padding formula:
  ///   p = (rH - textH) / 2      (vertical constraint sets the padding)
  ///   targetTextW = rW - 2*p    (horizontal constraint must match)
  ///   letterSpacing = (targetTextW - naturalTextW) / charCount
  /// This stretches "D   S   V" horizontally to fill the shape symmetrically.
  void _drawDSV(
    Canvas canvas,
    Offset center,
    double rW,
    double rH,
    double alpha, [
    double textScale = 1.0,
  ]) {
    final text = label;

    // ── Step 1: measure natural dimensions at a reference font size ──────────
    final ref = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // ── Step 2: scale font against INNER height so text size is independent of extra padding ──
    // inner height = shape height minus the extra padding added on each side.
    // Changing _kExtraPadding only affects whitespace; _kTextFillRatio controls text size.
    final innerH = rH - 2.0 * _kExtraPadding;
    final scale = (innerH * _kTextFillRatio) / ref.height;
    final fontSize = 100.0 * scale;
    final scaledH = ref.height * scale;
    final scaledWnatural = ref.width * scale;

    // ── Step 3: derive equal padding and required text width ─────────────────
    final p = (rH - scaledH) / 2; // equal vertical padding
    final targetW = rW - 2.0 * p; // matching horizontal constraint

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

  @override
  bool shouldRepaint(_MorphPainter old) =>
      old.progress != progress || old.label != label;
}
