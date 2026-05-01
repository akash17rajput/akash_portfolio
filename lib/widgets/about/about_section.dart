import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/portfolio_provider.dart';
import '../shared/animated_section.dart';
import '../shared/glass_card.dart';
import '../shared/section_header.dart';

/// About section with summary and highlight cards
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const AnimatedSection(
                visibilityKey: 'about-header',
                child: SectionHeader(
                  title: 'About Me',
                  subtitle:
                      'Passionate Flutter developer with a love for creating beautiful, performant applications.',
                ),
              ),

              const SizedBox(height: 60),

              // Main content
              isMobile
                  ? _MobileAboutContent(isDark: isDark)
                  : _DesktopAboutContent(isDark: isDark),

              const SizedBox(height: 60),

              // Highlight cards
              AnimatedSection(
                visibilityKey: 'about-highlights',
                delay: const Duration(milliseconds: 200),
                child: isMobile
                    ? Column(
                        children: _buildHighlightCards(context, isDark),
                      )
                    : Row(
                        children: _buildHighlightCards(context, isDark)
                            .map((card) => Expanded(child: card))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHighlightCards(BuildContext context, bool isDark) {
    final profile = context.watch<PortfolioProvider>().profile;
    final highlights = profile.aboutHighlights;

    return List.generate(highlights.length, (i) {
      final h = highlights[i];
      return Padding(
        padding: EdgeInsets.only(
          right:
              i < highlights.length - 1 && !ResponsiveHelper.isMobile(context)
                  ? 20
                  : 0,
          bottom: ResponsiveHelper.isMobile(context) ? 16 : 0,
        ),
        child: _HighlightCard(
          icon: _iconFromString(h.icon),
          title: h.title,
          subtitle: h.subtitle,
          isDark: isDark,
          delay: Duration(milliseconds: i * 100),
        ),
      );
    });
  }

  IconData _iconFromString(String name) {
    switch (name) {
      case 'work':
        return Icons.work_outline;
      case 'code':
        return Icons.code;
      case 'design_services':
        return Icons.design_services_outlined;
      default:
        return Icons.star_outline;
    }
  }
}

class _DesktopAboutContent extends StatelessWidget {
  final bool isDark;
  const _DesktopAboutContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Avatar/Visual
        Expanded(
          flex: 4,
          child: AnimatedSection(
            visibilityKey: 'about-avatar',
            child: _AboutVisual(isDark: isDark),
          ),
        ),
        const SizedBox(width: 60),
        // Right: Text content
        Expanded(
          flex: 6,
          child: AnimatedSection(
            visibilityKey: 'about-text',
            delay: const Duration(milliseconds: 200),
            child: _AboutText(isDark: isDark),
          ),
        ),
      ],
    );
  }
}

class _MobileAboutContent extends StatelessWidget {
  final bool isDark;
  const _MobileAboutContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSection(
          visibilityKey: 'about-avatar-mobile',
          child: _AboutVisual(isDark: isDark),
        ),
        const SizedBox(height: 40),
        AnimatedSection(
          visibilityKey: 'about-text-mobile',
          delay: const Duration(milliseconds: 200),
          child: _AboutText(isDark: isDark),
        ),
      ],
    );
  }
}

class _AboutVisual extends StatelessWidget {
  final bool isDark;
  const _AboutVisual({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PortfolioProvider>().profile;

    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Code snippet visual
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1117) : const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.neonBlue.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Window controls
                Row(
                  children: [
                    _dot(Colors.red),
                    const SizedBox(width: 6),
                    _dot(Colors.orange),
                    const SizedBox(width: 6),
                    _dot(Colors.green),
                    const Spacer(),
                    Text(
                      'developer.dart',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _codeLine('class', ' Developer {', Colors.blue, Colors.white),
                _codeLine('  final name', ' = "${profile.name}";', Colors.green,
                    Colors.white),
                _codeLine('  final role', ' = "Flutter Dev";', Colors.green,
                    Colors.white),
                _codeLine('  final exp', ' = "${profile.experience}";',
                    Colors.green, Colors.white),
                const SizedBox(height: 8),
                _codeLine(
                    '  List<String>', ' skills = [', Colors.blue, Colors.white),
                _codeLine('    ', '"Flutter",', Colors.orange, Colors.orange),
                _codeLine('    ', '"Firebase",', Colors.orange, Colors.orange),
                _codeLine('    ', '"Dart",', Colors.orange, Colors.orange),
                _codeLine('  ', '];', Colors.white, Colors.white),
                _codeLine('}', '', Colors.white, Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _codeLine(
      String keyword, String rest, Color keyColor, Color restColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: keyword,
              style: TextStyle(
                fontSize: 13,
                color: keyColor,
                fontFamily: 'monospace',
              ),
            ),
            TextSpan(
              text: rest,
              style: TextStyle(
                fontSize: 13,
                color: restColor.withOpacity(0.8),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutText extends StatelessWidget {
  final bool isDark;
  const _AboutText({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<PortfolioProvider>().profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Senior Flutter Developer | Building Scalable Cross-Platform Apps',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'I am ${profile.name}, a professional ${profile.role} with ${profile.experience} '
          'of experience in developing high-performance Flutter applications for Android, iOS, and Web. '
          'I specialize in creating scalable, user-friendly, and responsive cross-platform apps using modern technologies.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'My expertise includes Flutter UI development, Firebase integration, REST API integration, '
          'state management, and performance optimization. I focus on writing clean, maintainable code '
          'and delivering visually appealing digital experiences that drive user engagement and business growth.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),

        // Quick facts
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickFact(
                icon: Icons.location_on_outlined, text: profile.location),
            _QuickFact(icon: Icons.email_outlined, text: profile.email),
            _QuickFact(icon: Icons.phone_outlined, text: profile.phone),
          ],
        ),
      ],
    );
  }
}

class _QuickFact extends StatelessWidget {
  final IconData icon;
  final String text;

  const _QuickFact({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.neonBlue),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Duration delay;

  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return HoverGlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.neonGradient.createShader(bounds),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay)
        .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: delay);
  }
}
