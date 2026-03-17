import 'dart:math' as math;
import 'dart:ui';

import 'models/stroke_point.dart';

/// A smoothed rendering point: screen position, interpolated pressure,
/// and normalised velocity.
class SmoothedPoint {
  const SmoothedPoint(this.offset, this.pressure, this.velocity);

  final Offset offset;

  /// Interpolated pressure in [0.0, 1.0].
  final double pressure;

  /// Normalised stylus/touch speed in [0.0, 1.0].
  /// 0 = slow/stationary, 1 = fast.  Used to thin lines at speed.
  final double velocity;
}

/// Maximum expected stylus speed in logical pixels per millisecond.
/// Strokes faster than this are clamped to velocity 1.0.
const _kMaxVelocityPxPerMs = 3.0;

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

  /// Like [smooth] but also interpolates [StrokePoint.pressure] and computes
  /// a normalised velocity per segment so the painter can vary stroke width.
  ///
  /// Velocity is derived from consecutive point positions and timestamps:
  ///   v = distance_px / Δt_ms, clamped to [0, 1] via [_kMaxVelocityPxPerMs].
  ///
  /// The number of interpolated samples per segment is **adaptive**: slow
  /// segments get more samples (smoother curves), fast segments fewer
  /// (already straight enough).
  List<SmoothedPoint> smoothWithPressure(List<StrokePoint> points) {
    if (points.isEmpty) return const [];
    if (points.length == 1) {
      return [SmoothedPoint(Offset(points[0].x, points[0].y), points[0].pressure, 0.5)];
    }
    if (points.length < 4) {
      return points
          .map((p) => SmoothedPoint(Offset(p.x, p.y), p.pressure, 0.5))
          .toList();
    }

    final offsets = points.map((p) => Offset(p.x, p.y)).toList();
    final ps = [
      _phantom(offsets[0], offsets[1]),
      ...offsets,
      _phantom(offsets[offsets.length - 1], offsets[offsets.length - 2]),
    ];
    // Pressure and timestamp arrays aligned with ps.
    final pressures = [
      points[0].pressure,
      ...points.map((p) => p.pressure),
      points.last.pressure,
    ];
    final timestamps = [
      points[0].timestamp,
      ...points.map((p) => p.timestamp),
      points.last.timestamp,
    ];

    final result = <SmoothedPoint>[SmoothedPoint(ps[1], pressures[1], 0.5)];

    for (int i = 1; i < ps.length - 2; i++) {
      final p0 = ps[i - 1];
      final p1 = ps[i];
      final p2 = ps[i + 1];
      final p3 = ps[i + 2];

      final pStart = pressures[i];
      final pEnd   = pressures[i + 1];

      // ── Per-segment velocity ───────────────────────────────────────────────
      final dx  = p2.dx - p1.dx;
      final dy  = p2.dy - p1.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      final dtMs = (timestamps[i + 1] - timestamps[i]).abs().toDouble();
      final rawVel = dtMs > 0 ? dist / dtMs : 0.0;
      final segVel = (rawVel / _kMaxVelocityPxPerMs).clamp(0.0, 1.0);

      // ── Curvature at p1: angle between incoming and outgoing vectors ────────
      // cos θ = (v_in · v_out) / (|v_in| |v_out|); curvature ∈ [0, 2]
      // 0 = straight, 1 = 90°, 2 = U-turn.
      final inDx = p1.dx - p0.dx;
      final inDy = p1.dy - p0.dy;
      final inLen = math.sqrt(inDx * inDx + inDy * inDy);
      final outLen = dist; // dist already computed above
      double curvature = 0.0;
      if (inLen > 1e-6 && outLen > 1e-6) {
        final cosA = ((inDx * dx + inDy * dy) / (inLen * outLen)).clamp(-1.0, 1.0);
        curvature = 1.0 - cosA; // 0 = straight, 2 = 180° reversal
      }

      // Adaptive sample count: combines velocity (fast → fewer) and curvature
      // (tight corners → more).  Range: 6–22.
      final samples = (6
              + (curvature * 6).round().clamp(0, 10)
              + ((1.0 - segVel) * 4).round().clamp(0, 6))
          .clamp(6, 22);

      const t0 = 0.0;
      final t1 = t0 + _tj(p0, p1);
      final t2 = t1 + _tj(p1, p2);
      final t3 = t2 + _tj(p2, p3);

      final dt = t2 - t1;
      if (dt < 1e-10) {
        result.add(SmoothedPoint(p2, pEnd, segVel));
        continue;
      }

      for (int s = 1; s <= samples; s++) {
        final t        = t1 + dt * s / samples;
        final offset   = _catmullRom(p0, p1, p2, p3, t0, t1, t2, t3, t);
        final pressure = pStart + (pEnd - pStart) * s / samples;
        result.add(SmoothedPoint(offset, pressure, segVel));
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
