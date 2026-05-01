import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/nav_provider.dart';
import '../../providers/theme_provider.dart';

/// Sticky glassmorphism navbar with scroll effect and active section highlight
class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavProvider, ThemeProvider>(
      builder: (context, nav, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final isScrolled = nav.isScrolled;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isScrolled
                ? (isDark
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.8))
                : Colors.transparent,
            border: isScrolled
                ? Border(
                    bottom: BorderSide(
                      color: isDark
                          ? AppColors.neonBlue.withOpacity(0.15)
                          : AppColors.lightCardBorder,
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: isScrolled
                  ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.horizontalPadding(context),
                    vertical: 16,
                  ),
                  child: ResponsiveHelper.isMobile(context)
                      ? _MobileNavbar(nav: nav, themeProvider: themeProvider)
                      : _DesktopNavbar(nav: nav, themeProvider: themeProvider),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Desktop navigation bar
class _DesktopNavbar extends StatelessWidget {
  final NavProvider nav;
  final ThemeProvider themeProvider;

  const _DesktopNavbar({required this.nav, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;

    return Row(
      children: [
        // Logo
        _LogoWidget(isDark: isDark),

        const Spacer(),

        // Nav links
        Row(
          children: AppConstants.navSections.map((section) {
            final sectionId = section.toLowerCase();
            final isActive = nav.activeSection == sectionId;
            return _NavLink(
              label: section,
              isActive: isActive,
              isDark: isDark,
              onTap: () => nav.setActiveSection(sectionId),
            );
          }).toList(),
        ),

        const SizedBox(width: 24),

        // Theme toggle
        // _ThemeToggle(
        //   isDark: isDark,
        //   onToggle: themeProvider.toggleTheme,
        // ),

        const SizedBox(width: 16),

        // Hire Me CTA
        _HireMeButton(isDark: isDark),
      ],
    );
  }
}

/// Mobile navigation bar with hamburger menu
class _MobileNavbar extends StatelessWidget {
  final NavProvider nav;
  final ThemeProvider themeProvider;

  const _MobileNavbar({required this.nav, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;

    return Column(
      children: [
        Row(
          children: [
            _LogoWidget(isDark: isDark),
            const Spacer(),
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  nav.isMobileMenuOpen ? Icons.close : Icons.menu,
                  key: ValueKey(nav.isMobileMenuOpen),
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              onPressed: nav.toggleMobileMenu,
            ),
          ],
        ),

        // Mobile menu dropdown
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: nav.isMobileMenuOpen
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.85)
                        : Colors.white.withOpacity(0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.neonBlue.withOpacity(0.20)
                          : AppColors.lightCardBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      ...AppConstants.navSections.map((section) {
                        final sectionId = section.toLowerCase();
                        final isActive = nav.activeSection == sectionId;
                        return _MobileNavLink(
                          label: section,
                          isActive: isActive,
                          isDark: isDark,
                          onTap: () {
                            nav.setActiveSection(sectionId);
                            nav.closeMobileMenu();
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _LogoWidget extends StatelessWidget {
  final bool isDark;
  const _LogoWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.neonGradient.createShader(bounds),
      child: const Text(
        'AK.',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isActive || _isHovered
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.isActive
                      ? AppColors.neonBlue
                      : (_isHovered
                          ? AppColors.neonBlue
                          : (widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                ),
                child: Text(widget.label),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: widget.isActive ? 20 : 0,
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileNavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _MobileNavLink({
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.neonBlue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive
                ? AppColors.neonBlue
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark
              ? AppColors.neonBlue.withOpacity(0.2)
              : AppColors.lightCardBorder,
          border: Border.all(
            color: isDark
                ? AppColors.neonBlue.withOpacity(0.4)
                : AppColors.lightCardBorder,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDark ? 26 : 2,
              top: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isDark ? AppColors.neonGradient : null,
                  color: isDark ? null : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? AppColors.neonBlue.withOpacity(0.4)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 14,
                  color: isDark ? Colors.white : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HireMeButton extends StatefulWidget {
  final bool isDark;
  const _HireMeButton({required this.isDark});

  @override
  State<_HireMeButton> createState() => _HireMeButtonState();
}

class _HireMeButtonState extends State<_HireMeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.read<NavProvider>().setActiveSection('contact'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: _isHovered ? AppColors.neonGradient : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.neonBlue.withOpacity(_isHovered ? 0 : 0.6),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.neonBlue.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ]
                : [],
          ),
          child: Text(
            'Hire Me',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isHovered ? Colors.white : AppColors.neonBlue,
            ),
          ),
        ),
      ),
    );
  }
}
