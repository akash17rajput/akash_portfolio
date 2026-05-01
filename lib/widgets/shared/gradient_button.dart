import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Gradient CTA button with hover glow + ripple pulse on click
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final double? width;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.width,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with TickerProviderStateMixin {
  bool _isHovered = false;

  // Ripple on click
  late final AnimationController _rippleCtrl;
  late final Animation<double> _rippleRadius;
  late final Animation<double> _rippleOpacity;
  Offset _tapPos = Offset.zero;

  // Glow pulse while hovered
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rippleRadius = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );
    _rippleOpacity = Tween<double>(begin: 0.45, end: 0).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    setState(() => _isHovered = true);
    _glowCtrl.repeat(reverse: true);
  }

  void _onExit(PointerEvent _) {
    setState(() => _isHovered = false);
    _glowCtrl.stop();
    _glowCtrl.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _onTapDown(TapDownDetails d) {
    _tapPos = d.localPosition;
    _rippleCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([_glowAnim, _rippleCtrl]),
          builder: (context, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              transform: Matrix4.identity()
                ..translate(0.0, _isHovered ? -2.0 : 0.0),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: widget.isOutlined ? null : AppColors.neonGradient,
                borderRadius: BorderRadius.circular(12),
                border: widget.isOutlined
                    ? Border.all(
                        color: _isHovered
                            ? AppColors.neonBlue
                            : AppColors.neonBlue.withValues(alpha: 0.60),
                        width: 1.5,
                      )
                    : null,
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.neonBlue
                              .withValues(alpha: 0.25 + _glowAnim.value * 0.25),
                          blurRadius: 20 + _glowAnim.value * 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Button content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 18,
                              color: widget.isOutlined
                                  ? AppColors.neonBlue
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.isOutlined
                                  ? AppColors.neonBlue
                                  : Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ripple overlay
                    if (_rippleCtrl.value > 0)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ButtonRipplePainter(
                            center: _tapPos,
                            radiusFraction: _rippleRadius.value,
                            opacity: _rippleOpacity.value,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Ripple painter for button click effect
class _ButtonRipplePainter extends CustomPainter {
  final Offset center;
  final double radiusFraction;
  final double opacity;

  _ButtonRipplePainter({
    required this.center,
    required this.radiusFraction,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final maxR = math.sqrt(
          size.width * size.width + size.height * size.height,
        ) *
        0.7;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: opacity * 0.3);
    canvas.drawCircle(center, radiusFraction * maxR, paint);
  }

  @override
  bool shouldRepaint(_ButtonRipplePainter old) =>
      old.radiusFraction != radiusFraction || old.opacity != opacity;
}
