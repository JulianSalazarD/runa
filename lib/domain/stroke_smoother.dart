import 'dart:math' as math;
import 'dart:ui';

import 'models/stroke_point.dart';

/// Smooths a sequence of raw [StrokePoint]s into screen-ready [Offset]s
/// using Centripetal Catmull-Rom splines (α = 0.5).
///
/// This class has no Flutter widget dependencies (no `package:flutter`
/// imports) — it relies only on `dart:ui.Offset`, which is available
/// in every Flutter test environment.
///
/// The smoothed points are intended for rendering only; the original
/// [StrokePoint] data is preserved unchanged in the model.
class StrokeSmoother {
  const StrokeSmoother({this.alpha = 0.5, this.samplesPerSegment = 10});

  /// Catmull-Rom centripetal parameter.  0.5 = centripetal (recommended).
  final double alpha;

  /// Number of interpolated points generated between each pair of control
  /// points.
  final int samplesPerSegment;

  /// Returns smoothed [Offset]s for rendering.
  ///
  /// Edge cases:
  /// - 0 points → empty list
  /// - 1 point  → one Offset
  /// - 2–3 pts  → straight-line pass-through (no interpolation)
  /// - 4+ pts   → full Centripetal Catmull-Rom interpolation
  List<Offset> smooth(List<StrokePoint> points) {
    if (points.isEmpty) return const [];
    if (points.length == 1) {
      return [Offset(points[0].x, points[0].y)];
    }
    if (points.length < 4) {
      return points.map((p) => Offset(p.x, p.y)).toList();
    }

    // Extend with phantom (ghost) endpoints so the spline starts at
    // points[0] and ends at points[last].
    final offsets = points.map((p) => Offset(p.x, p.y)).toList();
    final ps = [
      _phantom(offsets[0], offsets[1]),
      ...offsets,
      _phantom(offsets[offsets.length - 1], offsets[offsets.length - 2]),
    ];

    final result = <Offset>[ps[1]]; // Emit the first real point.

    // Iterate over every inner segment [ps[i], ps[i+1]] with the surrounding
    // context ps[i-1] and ps[i+2] needed for the spline.
    for (int i = 1; i < ps.length - 2; i++) {
      final p0 = ps[i - 1];
      final p1 = ps[i];
      final p2 = ps[i + 1];
      final p3 = ps[i + 2];

      const t0 = 0.0;
      final t1 = t0 + _tj(p0, p1);
      final t2 = t1 + _tj(p1, p2);
      final t3 = t2 + _tj(p2, p3);

      final dt = t2 - t1;
      if (dt < 1e-10) {
        result.add(p2);
        continue;
      }

      for (int s = 1; s <= samplesPerSegment; s++) {
        final t = t1 + dt * s / samplesPerSegment;
        result.add(_catmullRom(p0, p1, p2, p3, t0, t1, t2, t3, t));
      }
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Centripetal parameterisation: distance^alpha between two Offsets.
  double _tj(Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final d = math.sqrt(dx * dx + dy * dy);
    return math.pow(d, alpha).toDouble().clamp(1e-10, double.infinity);
  }

  Offset _lerp(Offset a, Offset b, double t) =>
      Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);

  Offset _catmullRom(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t0,
    double t1,
    double t2,
    double t3,
    double t,
  ) {
    final a1 = _lerp(p0, p1, (t - t0) / (t1 - t0));
    final a2 = _lerp(p1, p2, (t - t1) / (t2 - t1));
    final a3 = _lerp(p2, p3, (t - t2) / (t3 - t2));
    final b1 = _lerp(a1, a2, (t - t0) / (t2 - t0));
    final b2 = _lerp(a2, a3, (t - t1) / (t3 - t1));
    return _lerp(b1, b2, (t - t1) / (t2 - t1));
  }

  static Offset _phantom(Offset anchor, Offset other) =>
      Offset(2 * anchor.dx - other.dx, 2 * anchor.dy - other.dy);
}
