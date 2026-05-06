import 'package:flutter/material.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║              RESPONSIVE SCALE HELPER                        ║
// ║  Base design width = 390 (iPhone 14/15 logical pixels).     ║
// ║  On narrower devices, everything scales proportionally      ║
// ║  but never below 0.72 to stay readable.                     ║
// ╚══════════════════════════════════════════════════════════════╝

class ResponsiveScale {
  static const double _baseWidth = 390.0;
  static const double _minScale = 0.72;
  static const double _maxScale = 1.0;

  final double scale;

  ResponsiveScale(double deviceWidth)
      : scale = (deviceWidth / _baseWidth).clamp(_minScale, _maxScale);

  /// Scale a layout dimension
  double s(double v) => v * scale;

  /// Scale a font size (same ratio, already clamped via constructor)
  double f(double v) => v * scale;

  /// Scale an EdgeInsets
  EdgeInsets insets(EdgeInsets e) => EdgeInsets.fromLTRB(
        e.left * scale,
        e.top * scale,
        e.right * scale,
        e.bottom * scale,
      );

  /// Symmetric EdgeInsets shorthand
  EdgeInsets sym({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h * scale, vertical: v * scale);

  /// Scaled BorderRadius
  BorderRadius radius(double r) => BorderRadius.circular(r * scale);
}
