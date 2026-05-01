import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HoverAnimatedCard
//
// Drop-in card wrapper that adds on-hover:
//   • Floating neon particle dots + network lines (CustomPainter, clipped)
//   • Animated gradient glow border
//   • Subtle lift (translateY -2px) + outer shadow glow
//   • Ripple / pulse burst on tap
//
// Performance notes:
//   • Painters only repaint when hovered (opacity > 0)
//   • Particle count defaults to 12 — keep ≤ 18 for 60 fps on web
//   • Uses a single AnimationController that drives both particles & border
// ─────────────────────────────────────────────────────────────────────────────

class HoverAnimatedCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final int particleCount;
  final Color glowColor;

  const HoverAnimatedCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.particleCount = 12,
    this.glowColor = AppColors.neonBlue,
  });

  @override
  State<HoverAnimatedCard> createState() => _HoverAnimatedCardState();
}

class _HoverAnimatedCardState extends State<HoverAnimatedCard>
    with TickerProviderStateMixin {
  // Drives particle opacity (0→1 on enter, 1→0 on exit) and border pulse
  late final AnimationController _hoverCtrl;
  late final Animation<double> _borderAnim;

  // Ripple on tap
  late final AnimationController _rippleCtrl;
  late final Animation<double> _rippleRadius;
  late final Animation<double> _rippleOpacity;

  bool _isHovered = false;
  Offset _tapPosition = Offset.zero;

  // Stable particle list — rebuilt only when card size changes
  List<_Particle> _particles = [];
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();

    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _borderAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeInOut),
    );

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _rippleRadius = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );
    _rippleOpacity = Tween<double>(begin: 0.45, end: 0).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    setState(() => _isHovered = true);
    _hoverCtrl.repeat(reverse: true);
  }

  void _onExit(PointerEvent _) {
    setState(() => _isHovered = false);
    _hoverCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _onTapDown(TapDownDetails d) {
    _tapPosition = d.localPosition;
    _rippleCtrl.forward(from: 0);
  }

  List<_Particle> _getParticles(Size size) {
    if (size == _lastSize && _particles.isNotEmpty) return _particles;
    _lastSize = size;
    final rng = math.Random();
    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle(
        x: rng.nextDouble() * size.width,
        y: rng.nextDouble() * size.height,
        radius: rng.nextDouble() * 1.8 + 0.8,
        speedX: (rng.nextDouble() - 0.5) * 0.55,
        speedY: (rng.nextDouble() - 0.5) * 0.55,
        phase: rng.nextDouble() * math.pi * 2,
      ),
    );
    return _particles;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -2.0 : 0.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.22),
                      blurRadius: 26,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.08),
                      blurRadius: 56,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
          // ClipRRect keeps ALL effects inside the card boundary
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                // ── 1. Glass background ───────────────────────────────────
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: BoxDecoration(
                        color: isDark
                            ? (_isHovered
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.05))
                            : (_isHovered
                                ? Colors.white.withValues(alpha: 0.92)
                                : Colors.white.withValues(alpha: 0.70)),
                      ),
                    ),
                  ),
                ),

                // ── 2. Particle + network painter ─────────────────────────
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _hoverCtrl,
                    builder: (context, _) {
                      // Skip painting entirely when invisible
                      if (_hoverCtrl.value < 0.01) return const SizedBox();
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final size = Size(
                            constraints.maxWidth.isFinite
                                ? constraints.maxWidth
                                : 300,
                            constraints.maxHeight.isFinite
                                ? constraints.maxHeight
                                : 200,
                          );
                          final particles = _getParticles(size);
                          return CustomPaint(
                            size: size,
                            painter: _CardParticlePainter(
                              particles: particles,
                              opacity: _hoverCtrl.value.clamp(0.0, 1.0),
                              glowColor: widget.glowColor,
                              time: _hoverCtrl.value,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // ── 3. Ripple painter ─────────────────────────────────────
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _rippleCtrl,
                    builder: (context, _) {
                      if (_rippleCtrl.value < 0.01) return const SizedBox();
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final size = Size(
                            constraints.maxWidth.isFinite
                                ? constraints.maxWidth
                                : 300,
                            constraints.maxHeight.isFinite
                                ? constraints.maxHeight
                                : 200,
                          );
                          return CustomPaint(
                            size: size,
                            painter: _RipplePainter(
                              center: _tapPosition,
                              radiusFraction: _rippleRadius.value,
                              opacity: _rippleOpacity.value,
                              maxRadius:
                                  math.max(size.width, size.height) * 0.8,
                              color: widget.glowColor,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // ── 4. Animated glow border ───────────────────────────────
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _borderAnim,
                    builder: (context, _) {
                      return IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(widget.borderRadius),
                            border: Border.all(
                              color: _isHovered
                                  ? widget.glowColor.withValues(
                                      alpha: 0.25 + _borderAnim.value * 0.45)
                                  : (isDark
                                      ? widget.glowColor.withValues(alpha: 0.18)
                                      : AppColors.lightCardBorder),
                              width: _isHovered ? 1.5 : 1.0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── 5. Content ────────────────────────────────────────────
                Padding(
                  padding: widget.padding ?? const EdgeInsets.all(24),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────
class _Particle {
  double x, y;
  final double radius;
  final double speedX, speedY;
  final double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.phase,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Particle + network lines painter
// ─────────────────────────────────────────────────────────────────────────────
class _CardParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double opacity;
  final Color glowColor;
  final double time;

  static const double _connectDist = 75.0;

  const _CardParticlePainter({
    required this.particles,
    required this.opacity,
    required this.glowColor,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;

    // Advance positions with soft wall bounce
    for (final p in particles) {
      p.x = (p.x + p.speedX).clamp(0.0, size.width);
      p.y = (p.y + p.speedY).clamp(0.0, size.height);
      // Reverse direction at walls
      if (p.x <= 0 || p.x >= size.width) {
        // flip handled by clamp; nudge back
        p.x = p.x <= 0 ? 1 : size.width - 1;
      }
      if (p.y <= 0 || p.y >= size.height) {
        p.y = p.y <= 0 ? 1 : size.height - 1;
      }
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final dotPaint = Paint()..style = PaintingStyle.fill;

    // Network lines
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = particles[i].x - particles[j].x;
        final dy = particles[i].y - particles[j].y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < _connectDist) {
          final a = opacity * (1 - dist / _connectDist) * 0.30;
          linePaint.color = glowColor.withValues(alpha: a);
          canvas.drawLine(
            Offset(particles[i].x, particles[i].y),
            Offset(particles[j].x, particles[j].y),
            linePaint,
          );
        }
      }
    }

    // Dots with halo
    for (final p in particles) {
      final pulse = 0.65 + 0.35 * math.sin(time * math.pi * 4 + p.phase);
      final a = opacity * pulse;

      // Soft halo
      dotPaint.color = glowColor.withValues(alpha: a * 0.20);
      canvas.drawCircle(Offset(p.x, p.y), p.radius * 3.2, dotPaint);

      // Core
      dotPaint.color = glowColor.withValues(alpha: a * 0.90);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_CardParticlePainter old) =>
      old.opacity != opacity || old.time != time;
}

// ─────────────────────────────────────────────────────────────────────────────
// Ripple painter
// ─────────────────────────────────────────────────────────────────────────────
class _RipplePainter extends CustomPainter {
  final Offset center;
  final double radiusFraction;
  final double opacity;
  final double maxRadius;
  final Color color;

  const _RipplePainter({
    required this.center,
    required this.radiusFraction,
    required this.opacity,
    required this.maxRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color.withValues(alpha: opacity * 0.65);
    canvas.drawCircle(center, radiusFraction * maxRadius, paint);

    if (radiusFraction > 0.12) {
      paint.color = color.withValues(alpha: opacity * 0.28);
      canvas.drawCircle(center, (radiusFraction - 0.10) * maxRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.radiusFraction != radiusFraction || old.opacity != opacity;
}
