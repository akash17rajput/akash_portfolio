import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../shared/animated_section.dart';
import '../shared/hover_animated_card.dart';
import '../shared/section_header.dart';
import '../../models/portfolio_models.dart';
import '../../providers/portfolio_provider.dart';

/// Skills section with animated progress bars and hover particle cards
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.horizontalPadding(context),
        vertical: 100,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.20)
            : Colors.white.withValues(alpha: 0.30),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const AnimatedSection(
                visibilityKey: 'skills-header',
                child: SectionHeader(
                  title: 'Skills & Expertise',
                  subtitle:
                      'Technologies and tools I use to bring ideas to life.',
                ),
              ),

              const SizedBox(height: 60),

              // Skills grid
              AnimatedSection(
                visibilityKey: 'skills-grid',
                delay: const Duration(milliseconds: 200),
                child: isMobile
                    ? Column(
                        children: _buildSkillCards(context, isDark),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildSkillCards(context, isDark)
                            .map((card) => Expanded(child: card))
                            .toList(),
                      ),
              ),

              const SizedBox(height: 60),

              // Tech stack badges
              AnimatedSection(
                visibilityKey: 'tech-badges',
                delay: const Duration(milliseconds: 400),
                child: _TechStackBadges(isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSkillCards(BuildContext context, bool isDark) {
    final skills = context.watch<PortfolioProvider>().skills;
    return List.generate(skills.length, (i) {
      return Padding(
        padding: EdgeInsets.only(
          right: i < skills.length - 1 && !ResponsiveHelper.isMobile(context)
              ? 20
              : 0,
          bottom: ResponsiveHelper.isMobile(context) ? 20 : 0,
        ),
        child: _SkillCard(
          category: skills[i].category,
          skills: skills[i].skills,
          isDark: isDark,
          delay: Duration(milliseconds: i * 150),
        ),
      );
    });
  }
}

// ─── Skill card with particle hover ──────────────────────────────────────────

class _SkillCard extends StatelessWidget {
  final String category;
  final List<SkillModel> skills;
  final bool isDark;
  final Duration delay;

  const _SkillCard({
    required this.category,
    required this.skills,
    required this.isDark,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return HoverAnimatedCard(
      padding: const EdgeInsets.all(28),
      particleCount: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                category,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Skill bars
          ...skills.map((skill) => _AnimatedSkillBar(
                name: skill.name,
                level: skill.level,
                isDark: isDark,
                delay: delay,
              )),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.easeOutBack,
          delay: delay,
        )
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: delay);
  }
}

// ─── Animated skill progress bar ─────────────────────────────────────────────

class _AnimatedSkillBar extends StatefulWidget {
  final String name;
  final double level;
  final bool isDark;
  final Duration delay;

  const _AnimatedSkillBar({
    required this.name,
    required this.level,
    required this.isDark,
    required this.delay,
  });

  @override
  State<_AnimatedSkillBar> createState() => _AnimatedSkillBarState();
}

class _AnimatedSkillBarState extends State<_AnimatedSkillBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.level).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.delay + const Duration(milliseconds: 400), () {
      if (mounted && !_hasAnimated) {
        _hasAnimated = true;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) => Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neonBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.neonGradient,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonBlue.withValues(alpha: 0.40),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tech stack badges ────────────────────────────────────────────────────────

class _TechStackBadges extends StatelessWidget {
  final bool isDark;

  const _TechStackBadges({required this.isDark});

  static const List<Map<String, dynamic>> _techStack = [
    {'name': 'Flutter', 'color': 0xFF54C5F8},
    {'name': 'Dart', 'color': 0xFF00B4AB},
    {'name': 'Firebase', 'color': 0xFFFFCA28},
    {'name': 'Firestore', 'color': 0xFFFF6D00},
    {'name': 'Provider', 'color': 0xFF7C3AED},
    {'name': 'Riverpod', 'color': 0xFF0EA5E9},
    {'name': 'REST API', 'color': 0xFF10B981},
    {'name': 'Git', 'color': 0xFFF05032},
    {'name': 'VS Code', 'color': 0xFF007ACC},
    {'name': 'Figma', 'color': 0xFFF24E1E},
    {'name': 'Android Studio', 'color': 0xFF3DDC84},
    {'name': 'CI/CD', 'color': 0xFF6366F1},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Tech Stack',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _techStack.map((tech) {
              final color = Color(tech['color'] as int);
              return _TechBadge(
                name: tech['name'] as String,
                color: color,
                isDark: isDark,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Tech badge with glow pulse on hover (uses HoverAnimatedCard with 4 particles)
class _TechBadge extends StatefulWidget {
  final String name;
  final Color color;
  final bool isDark;

  const _TechBadge({
    required this.name,
    required this.color,
    required this.isDark,
  });

  @override
  State<_TechBadge> createState() => _TechBadgeState();
}

class _TechBadgeState extends State<_TechBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: HoverAnimatedCard(
        borderRadius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        particleCount: 4,
        glowColor: widget.color,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_isHovered ? 0.30 : 0.14),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _isHovered
                    ? widget.color
                    : (widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              child: Text(widget.name),
            ),
          ],
        ),
      ),
    );
  }
}
