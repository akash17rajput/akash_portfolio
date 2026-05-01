
library;


import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Magnetic gather + burst particle system
//
// Behaviour:
//   • Idle          — particles drift slowly with sinusoidal motion
//   • Cursor still  — nearby particles are ATTRACTED toward cursor (gather)
//   • Cursor moves  — fast movement triggers a REPULSION BURST (spread)
//   • After burst   — particles spring back to their home positions smoothly
//
// Physics per particle:
//   attractForce  = strength * (1 - dist/radius)²   [toward cursor]
//   repelForce    = burstStrength * cursorSpeed * falloff  [away from cursor]
//   springForce   = stiffness * (home - pos)
//   velocity      = (velocity + forces * dt) * damping
// ─────────────────────────────────────────────────────────────────────────────

/// Global cursor position — written by HomeScreen's top-level MouseRegion.
final CursorNotifier globalCursor = CursorNotifier();

class CursorNotifier extends ValueNotifier<Offset> {
  CursorNotifier() : super(const Offset(-9999, -9999));
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

class InteractiveParticles extends StatefulWidget {
  final int count;
  final Color color;
  final Color accentColor;
  final bool isDark;

  const InteractiveParticles({
    super.key,
    this.count = 1150,
    this.color = AppColors.neonBlue,
    this.accentColor = AppColors.neonBlue,
    this.isDark = true,
  });

  @override
  State<InteractiveParticles> createState() => _InteractiveParticlesState();
}

class _InteractiveParticlesState extends State<InteractiveParticles>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final List<_Particle> _particles;
  late final _RepaintNotifier _repaintNotifier;
  late _ParticlesPainter _painter;

  Duration _lastTime = Duration.zero;

  // Cursor velocity tracking
  Offset _prevCursor = const Offset(-9999, -9999);
  double _cursorSpeed = 0; // px/s
  double _burstEnergy = 0; // 0..1, decays over time

  @override
  void initState() {
    super.initState();
    final rng = math.Random(99991);
    _particles = List.generate(widget.count, (i) => _Particle.random(rng, i));
    _repaintNotifier = _RepaintNotifier();
    _painter = _ParticlesPainter(
      particles: _particles,
      color: widget.color,
      accentColor: widget.accentColor,
      isDark: widget.isDark,
      repaint: _repaintNotifier,
    );
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTime == Duration.zero
        ? 0.016
        : (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;
    final safeDt = dt.clamp(0.0, 0.05);

    final size = _painter.lastSize;
    if (size == Size.zero) return;

    final cursor = globalCursor.value;
    final cursorActive = cursor.dx > -1000;

    // ── Cursor velocity ───────────────────────────────────────────────────
    if (cursorActive && _prevCursor.dx > -1000 && safeDt > 0) {
      final ddx = cursor.dx - _prevCursor.dx;
      final ddy = cursor.dy - _prevCursor.dy;
      final rawSpeed = math.sqrt(ddx * ddx + ddy * ddy) / safeDt;
      // Smooth speed with exponential moving average
      _cursorSpeed = _cursorSpeed * 0.6 + rawSpeed * 0.4;
    } else if (!cursorActive) {
      _cursorSpeed = 0;
    }
    _prevCursor = cursor;

    // ── Burst energy: spikes on fast movement, decays to 0 ───────────────
    // Threshold: > 400 px/s counts as "fast"
    const speedThreshold = 400.0;
    if (_cursorSpeed > speedThreshold) {
      final spike = ((_cursorSpeed - speedThreshold) / 800.0).clamp(0.0, 1.0);
      _burstEnergy = (_burstEnergy + spike * 0.6).clamp(0.0, 1.0);
    }
    // Decay burst energy over ~0.5s
    _burstEnergy = (_burstEnergy - safeDt * 2.2).clamp(0.0, 1.0);

    // ── Update particles ──────────────────────────────────────────────────
    final elapsedSeconds = elapsed.inMicroseconds / 1000000.0;
    for (final p in _particles) {
      p.update(safeDt, cursor, size, _burstEnergy, cursorActive, elapsedSeconds);
    }

    _painter
      ..cursor = cursor
      ..elapsed = elapsedSeconds
      ..burstEnergy = _burstEnergy
      ..cursorSpeed = _cursorSpeed;

    _repaintNotifier.notify();
  }

  @override
  void didUpdateWidget(InteractiveParticles old) {
    super.didUpdateWidget(old);
    if (old.color != widget.color || old.accentColor != widget.accentColor) {
      _painter = _ParticlesPainter(
        particles: _particles,
        color: widget.color,
        accentColor: widget.accentColor,
        isDark: widget.isDark,
        repaint: _repaintNotifier,
      );
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaintNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _painter,
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Repaint trigger
// ─────────────────────────────────────────────────────────────────────────────

class _RepaintNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// ─────────────────────────────────────────────────────────────────────────────
// Physics constants
// ─────────────────────────────────────────────────────────────────────────────

const double _kRadius = 180.0; // cursor influence radius (px)
const double _kAttractStr = 12000.0; // attraction force when cursor is still
const double _kBurstStr = 35000.0; // repulsion force on fast cursor move
const double _kSpringK = 3.8; // spring stiffness back to home
const double _kDamping = 0.78; // velocity damping (per frame)
const double _kGatherRadius = 55.0; // particles cluster within this radius

// ─────────────────────────────────────────────────────────────────────────────
// Particle
// ─────────────────────────────────────────────────────────────────────────────

class _Particle {
  final double homeX, homeY; // normalised (0..1)
  final double driftAmp;
  final double freqX, freqY;
  final double phaseX, phaseY;
  final double baseSize;
  final double baseOpacity;
  final bool isStar;

  double x = -1, y = -1;
  double vx = 0, vy = 0;

  _Particle({
    required this.homeX,
    required this.homeY,
    required this.driftAmp,
    required this.freqX,
    required this.freqY,
    required this.phaseX,
    required this.phaseY,
    required this.baseSize,
    required this.baseOpacity,
    required this.isStar,
  });

  factory _Particle.random(math.Random rng, int i) => _Particle(
        homeX: rng.nextDouble(),
        homeY: rng.nextDouble(),
        driftAmp: rng.nextDouble() * 18 + 6,
        freqX: rng.nextDouble() * 0.30 + 0.06,
        freqY: rng.nextDouble() * 0.30 + 0.06,
        phaseX: rng.nextDouble() * math.pi * 2,
        phaseY: rng.nextDouble() * math.pi * 2,
        baseSize: rng.nextDouble() * 2.4 + 0.9,
        baseOpacity: rng.nextDouble() * 0.38 + 0.10,
        isStar: rng.nextDouble() < 0.20,
      );

  void update(
    double dt,
    Offset cursor,
    Size size,
    double burstEnergy,
    bool cursorActive,
    double elapsedSeconds,
  ) {
    // ── Drifting home target ──────────────────────────────────────────────
    final tx = homeX * size.width + math.sin(elapsedSeconds * freqX + phaseX) * driftAmp;
    final ty = homeY * size.height + math.cos(elapsedSeconds * freqY + phaseY) * driftAmp;

    // Initialise position on first frame
    if (x < 0) {
      x = tx;
      y = ty;
      return;
    }

    // ── Spring force toward drifting home ────────────────────────────────
    final springFx = (tx - x) * _kSpringK;
    final springFy = (ty - y) * _kSpringK;

    // ── Cursor interaction ────────────────────────────────────────────────
    double cfx = 0, cfy = 0;

    if (cursorActive) {
      final dx = x - cursor.dx;
      final dy = y - cursor.dy;
      final dist2 = dx * dx + dy * dy;
      final dist = math.sqrt(dist2);

      if (dist < _kRadius && dist > 0.5) {
        final falloff = 1.0 - dist / _kRadius; // 1 at cursor, 0 at edge
        final falloff2 = falloff * falloff;

        if (burstEnergy > 0.05) {
          // ── BURST MODE: repel outward ─────────────────────────────────
          final strength = _kBurstStr * burstEnergy * falloff2 / dist;
          cfx = dx * strength;
          cfy = dy * strength;
        } else {
          // ── GATHER MODE: attract toward cursor ────────────────────────
          // Pull toward a ring at _kGatherRadius so particles orbit
          // rather than collapsing to a single point
          final pullDist = dist - _kGatherRadius;
          if (pullDist > 0) {
            final strength = _kAttractStr * falloff2 / dist;
            cfx = -(dx / dist) * strength; // toward cursor
            cfy = -(dy / dist) * strength;
          }
        }
      }
    }

    // ── Integrate ─────────────────────────────────────────────────────────
    vx = (vx + (springFx + cfx) * dt) * _kDamping;
    vy = (vy + (springFy + cfy) * dt) * _kDamping;
    x += vx * dt;
    y += vy * dt;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> _particles;
  final Color color;
  final Color accentColor;
  final bool isDark;

  Offset cursor = const Offset(-9999, -9999);
  double elapsed = 0;
  double burstEnergy = 0;
  double cursorSpeed = 0;
  Size lastSize = Size.zero;

  _ParticlesPainter({
    required List<_Particle> particles,
    required this.color,
    required this.accentColor,
    required this.isDark,
    required Listenable repaint,
  })  : _particles = particles,
        super(repaint: repaint);

  @override
  bool shouldRepaint(_ParticlesPainter old) => false;

  @override
  void paint(Canvas canvas, Size size) {
    lastSize = size;
    final cursorActive = cursor.dx > -1000;

    // ── Cursor glow ───────────────────────────────────────────────────────
    if (cursorActive) _drawCursorGlow(canvas);

    // ── Particles ─────────────────────────────────────────────────────────
    for (final p in _particles) {
      if (p.x < 0) continue;

      final dx = p.x - cursor.dx;
      final dy = p.y - cursor.dy;
      final dist = math.sqrt(dx * dx + dy * dy);

      // Proximity: 1 at cursor, 0 at radius edge
      final proximity =
          cursorActive ? (1.0 - dist / _kRadius).clamp(0.0, 1.0) : 0.0;

      // Burst makes particles brighter and bigger
      final burstBoost = burstEnergy * proximity;
      final alpha =
          (p.baseOpacity + proximity * 0.5 + burstBoost * 0.3).clamp(0.0, 1.0);
      final radius = p.baseSize + proximity * 2.5 + burstBoost * 3.0;
      final pulse = 0.88 + 0.12 * math.sin(elapsed * 1.6 + p.phaseX);

      // Colour shifts toward accent when gathered, white-hot on burst
      final Color c;
      if (burstBoost > 0.3) {
        c = Color.lerp(accentColor, isDark ? Colors.white : color, burstBoost * 0.4)!;
      } else if (proximity > 0.05) {
        c = Color.lerp(color, accentColor, proximity * 0.7)!;
      } else {
        c = color;
      }

      final paintColor = c.withValues(alpha: alpha * pulse);

      if (p.isStar) {
        _drawSparkle(canvas, Offset(p.x, p.y), radius * 1.5, paintColor);
      } else {
        _drawGlowDot(canvas, Offset(p.x, p.y), radius, paintColor, proximity);
      }
    }
  }

  void _drawGlowDot(
      Canvas canvas, Offset pos, double r, Color c, double bloom) {
    if (bloom > 0.08) {
      canvas.drawCircle(
        pos,
        r * 4.5,
        Paint()
          ..shader = RadialGradient(colors: [
            c.withValues(alpha: c.a * 0.20 * bloom),
            c.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: pos, radius: r * 4.5))
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = c
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isDark ? r * 0.85 : r * 0.4)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      pos,
      r * (isDark ? 0.36 : 0.6),
      Paint()
        ..color = (isDark ? Colors.white : c).withValues(alpha: c.a * (isDark ? 0.5 : 0.95))
        ..style = PaintingStyle.fill,
    );
  }

  void _drawSparkle(Canvas canvas, Offset pos, double size, Color c) {
    final path = Path();
    const arms = 4;
    for (int i = 0; i < arms * 2; i++) {
      final angle = (i * math.pi / arms) - math.pi / 2;
      final r = i.isEven ? size : size * 0.30;
      final px = pos.dx + r * math.cos(angle);
      final py = pos.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = c
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * (isDark ? 0.4 : 0.2))
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      pos,
      size * (isDark ? 0.20 : 0.30),
      Paint()..color = (isDark ? Colors.white : c).withValues(alpha: c.a * (isDark ? 0.8 : 1.0)),
    );
  }

  void _drawCursorGlow(Canvas canvas) {
    // Burst ring — expands and fades when burstEnergy > 0
    if (burstEnergy > 0.05) {
      final burstR = _kRadius * (0.3 + burstEnergy * 0.7);
      canvas.drawCircle(
        cursor,
        burstR,
        Paint()
          ..color = accentColor.withValues(alpha: burstEnergy * 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + burstEnergy * 2.0
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, 8 + burstEnergy * 12),
      );
    }

    // Gather halo — glows when cursor is still
    final gatherGlow = (1.0 - burstEnergy).clamp(0.0, 1.0);
    canvas.drawCircle(
      cursor,
      _kRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.10 * gatherGlow),
            accentColor.withValues(alpha: 0.05 * gatherGlow),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: cursor, radius: _kRadius))
        ..style = PaintingStyle.fill,
    );

    // Pulsing inner ring
    final ringR = _kRadius * 0.28 * (0.88 + 0.12 * math.sin(elapsed * 3.5));
    canvas.drawCircle(
      cursor,
      ringR,
      Paint()
        ..color = color.withValues(
            alpha: (0.30 + 0.12 * math.sin(elapsed * 3.5)) * gatherGlow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // Bright dot at cursor tip
    canvas.drawCircle(
      cursor,
      4.5,
      Paint()
        ..color = color.withValues(alpha: 0.70)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..style = PaintingStyle.fill,
    );
  }
}
