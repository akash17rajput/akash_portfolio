import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/scroll_helper.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/navbar/navbar_widget.dart';
import '../../widgets/hero/hero_section.dart';
import '../../widgets/about/about_section.dart';
// import '../../widgets/shared/interactive_particles copy.dart';
import '../../widgets/skills/skills_section.dart';
import '../../widgets/experience/experience_section.dart';
import '../../widgets/projects/projects_section.dart';
import '../../widgets/contact/contact_section.dart';
import '../../widgets/shared/footer_widget.dart';
import '../../widgets/shared/interactive_particles.dart';
import '../../widgets/shared/scroll_to_top_button.dart';

/// Main portfolio home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      // ── Single top-level MouseRegion — captures cursor over the ENTIRE page,
      //    including the scrollable content, navbar, and all child widgets.
      //    Writes to globalCursor so InteractiveParticles can read it every tick
      //    without being blocked by the widget tree above it.
      body: MouseRegion(
        opaque: false,
        // onHover: (e) => cursorNotifier.value = e.localPosition,
        // onExit: (_) => cursorNotifier.value = const Offset(-9999, -9999),
        onHover: (e) => globalCursor.value = e.localPosition,
        onExit: (_) => globalCursor.value = const Offset(-9999, -9999),

        child: Stack(
          children: [
            // ── Layer 0: Full-page gradient background ──────────────────
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF050A14),
                            Color(0xFF080F1E),
                            Color(0xFF050A14),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [
                            Color(0xFFF0F4FF),
                            Color(0xFFE8F0FE),
                            Color(0xFFF0F4FF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
              ),
            ),

            // ── Layer 1: Interactive particle canvas ────────────────────
            // IgnorePointer so clicks/scrolls pass through to content.
            // Cursor is fed via globalCursor notifier, NOT via MouseRegion
            // on the particle widget itself — that's the key fix.
            Positioned.fill(
              child: IgnorePointer(
                child: InteractiveParticles(
                  // count: ResponsiveHelper.isMobile(context)
                  //     ? 420
                  //     : ResponsiveHelper.isTablet(context)
                  //         ? 700
                  //         : 1150,
                  color: isDark
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFF0055BB),
                  accentColor: isDark
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFF4338CA),
                  isDark: isDark,
                ),
              ),
            ),

            // ── Layer 2: Scrollable page content ────────────────────────
            SingleChildScrollView(
              controller: ScrollHelper.scrollController,
              child: Column(
                children: [
                  _Wrap(
                    sectionKey:
                        ScrollHelper.sectionKeys[AppConstants.heroSection]!,
                    child: const HeroSection(),
                  ),
                  _Wrap(
                    sectionKey:
                        ScrollHelper.sectionKeys[AppConstants.aboutSection]!,
                    child: const AboutSection(),
                  ),
                  _Wrap(
                    sectionKey:
                        ScrollHelper.sectionKeys[AppConstants.skillsSection]!,
                    child: const SkillsSection(),
                  ),
                  _Wrap(
                    sectionKey: ScrollHelper
                        .sectionKeys[AppConstants.experienceSection]!,
                    child: const ExperienceSection(),
                  ),
                  _Wrap(
                    sectionKey:
                        ScrollHelper.sectionKeys[AppConstants.projectsSection]!,
                    child: const ProjectsSection(),
                  ),
                  _Wrap(
                    sectionKey:
                        ScrollHelper.sectionKeys[AppConstants.contactSection]!,
                    child: const ContactSection(),
                  ),
                  const FooterWidget(),
                ],
              ),
            ),

            // ── Layer 3: Sticky navbar ───────────────────────────────────
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: NavbarWidget(),
            ),

            // ── Layer 4: Scroll to top button ────────────────────────────
            const ScrollToTopButton(),
          ],
        ),
      ),
    );
  }
}

class _Wrap extends StatelessWidget {
  final GlobalKey sectionKey;
  final Widget child;
  const _Wrap({required this.sectionKey, required this.child});

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: sectionKey, child: child);
}
