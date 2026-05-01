import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// Reusable section header with animated title and subtitle
class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool centerAlign;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.centerAlign = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment:
          centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Gradient title
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.neonGradient.createShader(bounds),
          child: Text(
            title,
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: centerAlign ? TextAlign.center : TextAlign.start,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0, duration: 600.ms),

        const SizedBox(height: 8),

        // Animated underline
        if (centerAlign)
          Center(
            child: Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ).animate().scaleX(
                begin: 0,
                end: 1,
                duration: 600.ms,
                delay: 200.ms,
                curve: Curves.easeOut,
              )
        else
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate().scaleX(
                begin: 0,
                end: 1,
                duration: 600.ms,
                delay: 200.ms,
                curve: Curves.easeOut,
              ),

        const SizedBox(height: 16),

        // Subtitle
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            height: 1.6,
          ),
          textAlign: centerAlign ? TextAlign.center : TextAlign.start,
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 300.ms)
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms),
      ],
    );
  }
}
