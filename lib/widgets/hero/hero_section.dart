import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/nav_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../services/firebase_service.dart';
import '../shared/gradient_button.dart';

/// Hero section — transparent background so the global particle layer shows through
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.isMobile(context)
          ? null
          : MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // Subtle gradient orbs (decorative, not the particle system)
          Positioned(
            top: -100,
            right: -100,
            child: _GlowOrb(
              color: AppColors.neonBlue.withOpacity(0.12),
              size: 500,
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _GlowOrb(
              color: AppColors.accentPurple.withOpacity(0.08),
              size: 400,
            ),
          ),

          // Main content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.horizontalPadding(context),
                vertical: ResponsiveHelper.isMobile(context) ? 40 : 80,
              ),
              child: ResponsiveHelper.isMobile(context)
                  ? _MobileHeroContent()
                  : _DesktopHeroContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: _HeroText(),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 4,
          child: _HeroAvatar(),
        ),
      ],
    );
  }
}

class _MobileHeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeroAvatar(),
        const SizedBox(height: 40),
        _HeroText(),
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final profile = context.watch<PortfolioProvider>().profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Greeting badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neonBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonBlue.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.neonBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Available for work',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.neonBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.2, end: 0, duration: 600.ms),

        const SizedBox(height: 20),

        // Name
        Text(
          'Hi, I\'m',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 100.ms)
            .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 100.ms),

        GestureDetector(
          onLongPress: () async {
            // Hidden trigger to seed data to Firebase
            await FirebaseService().seedPortfolioData();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Firebase seeded successfully!')),
              );
            }
          },
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.neonGradient.createShader(bounds),
            child: Text(
              profile.name,
              style: theme.textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontSize: isMobile ? 40 : 56,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 200.ms),

        const SizedBox(height: 16),

        // Typing animation
        Row(
          children: [
            Text(
              '< ',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                color: AppColors.accentPurple,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            AnimatedTextKit(
              animatedTexts: profile.typingTexts
                  .map(
                    (text) => TypewriterAnimatedText(
                      text,
                      textStyle: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neonBlue,
                      ),
                      speed: const Duration(milliseconds: 80),
                    ),
                  )
                  .toList(),
              repeatForever: true,
              pause: const Duration(milliseconds: 1500),
            ),
            Text(
              ' />',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                color: AppColors.accentPurple,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

        const SizedBox(height: 20),

        Text(
          'Experienced Flutter Developer specializing in high-performance cross-platform '
          'applications for Android, iOS, and Web using Flutter and Firebase. Skilled in UI/UX design, '
          'API integration, and scalable app development with clean, maintainable code.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            height: 1.7,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),

        const SizedBox(height: 36),

        // CTA Buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            GradientButton(
              label: 'View Projects',
              icon: Icons.work_outline,
              onPressed: () =>
                  context.read<NavProvider>().setActiveSection('projects'),
            ),
            GradientButton(
              label: 'Download Resume',
              icon: Icons.download_outlined,
              isOutlined: true,
              onPressed: () async {
                final uri = Uri.parse(profile.resumeUrl);
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
            ),
            GradientButton(
              label: 'Hire Me',
              icon: Icons.send_outlined,
              isOutlined: true,
              onPressed: () =>
                  context.read<NavProvider>().setActiveSection('contact'),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 500.ms)
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 500.ms),

        const SizedBox(height: 40),

        // Social links
        _SocialLinks().animate().fadeIn(duration: 600.ms, delay: 600.ms),
      ],
    );
  }
}

class _HeroAvatar extends StatefulWidget {
  @override
  State<_HeroAvatar> createState() => _HeroAvatarState();
}

class _HeroAvatarState extends State<_HeroAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<PortfolioProvider>().profile;
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Center(
        child: SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Outer glow ring
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.neonBlue.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Avatar container
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.neonGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonBlue.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1A2540), const Color(0xFF0D1526)]
                            : [Colors.white, const Color(0xFFE2E8F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: profile.profileUrl.isNotEmpty
                          ? Image.network(
                              profile.profileUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                    'Error loading profile image: $error');
                                return Text(
                                  'AK',
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w800,
                                    foreground: Paint()
                                      ..shader = AppColors.neonGradient
                                          .createShader(const Rect.fromLTWH(
                                              0, 0, 200, 100)),
                                  ),
                                );
                              },
                            )
                          : Text(
                              'AK',
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w800,
                                foreground: Paint()
                                  ..shader = AppColors.neonGradient
                                      .createShader(
                                          const Rect.fromLTWH(0, 0, 200, 100)),
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // Floating tech badges
              ..._buildFloatingBadges(isDark),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 300.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 800.ms,
          delay: 300.ms,
        );
  }

  List<Widget> _buildFloatingBadges(bool isDark) {
    final badges = [
      ('Flutter', Icons.phone_android, const Offset(160 + 90, 160 - 100)),
      (
        'Firebase',
        Icons.local_fire_department,
        const Offset(160 - 130, 160 - 80)
      ),
      ('Dart', Icons.code, const Offset(160 + 80, 160 + 80)),
      ('UI/UX', Icons.design_services, const Offset(160 - 120, 160 + 90)),
    ];

    return badges.map((badge) {
      return Positioned(
        left: badge.$3.dx,
        top: badge.$3.dy,
        child: _FloatingBadge(label: badge.$1, icon: badge.$2, isDark: isDark),
      );
    }).toList();
  }
}

class _FloatingBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const _FloatingBadge({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard
            : AppColors.lightCardBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonBlue.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neonBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PortfolioProvider>().profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final links = [
      (Icons.code, profile.githubUrl, 'GitHub'),
      (Icons.work, profile.linkedinUrl, 'LinkedIn'),
      // (Icons.alternate_email, profile.twitterUrl, 'Twitter'),
    ];

    return Row(
      children: links.map((link) {
        return _SocialIcon(
          icon: link.$1,
          url: link.$2,
          tooltip: link.$3,
          isDark: isDark,
        );
      }).toList(),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String url;
  final String tooltip;
  final bool isDark;

  const _SocialIcon({
    required this.icon,
    required this.url,
    required this.tooltip,
    required this.isDark,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            final uri = Uri.parse(widget.url);
            if (await canLaunchUrl(uri)) launchUrl(uri);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 12),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.neonBlue.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered
                    ? AppColors.neonBlue.withOpacity(0.6)
                    : AppColors.neonBlue.withOpacity(0.2),
              ),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: _isHovered
                  ? AppColors.neonBlue
                  : (widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
