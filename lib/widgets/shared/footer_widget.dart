import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

/// Footer widget with copyright and quick links
class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.horizontalPadding(context),
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.5)
            : AppColors.lightCardBorder.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.neonBlue.withOpacity(0.1)
                : AppColors.lightCardBorder,
          ),
        ),
      ),
      child: isMobile
          ? Column(
              children: [
                _LogoAndTagline(isDark: isDark),
                const SizedBox(height: 20),
                _Copyright(isDark: isDark),
              ],
            )
          : Row(
              children: [
                _LogoAndTagline(isDark: isDark),
                const Spacer(),
                _Copyright(isDark: isDark),
              ],
            ),
    );
  }
}

class _LogoAndTagline extends StatelessWidget {
  final bool isDark;
  const _LogoAndTagline({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.neonGradient.createShader(bounds),
          child: const Text(
            'AK.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '— Built with Flutter & Firebase',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _Copyright extends StatelessWidget {
  final bool isDark;
  const _Copyright({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      '© ${DateTime.now().year} ${AppConstants.developerName}. All rights reserved.',
      style: TextStyle(
        fontSize: 13,
        color:
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
    );
  }
}
