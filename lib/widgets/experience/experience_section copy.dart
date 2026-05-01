import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/portfolio_models.dart';
import '../../providers/portfolio_provider.dart';
import '../shared/animated_section.dart';
import '../shared/glass_card.dart';
import '../shared/section_header.dart';

/// Experience section with animated timeline UI
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final experienceList = context.watch<PortfolioProvider>().experience;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.horizontalPadding(context),
        vertical: 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const AnimatedSection(
                visibilityKey: 'exp-header',
                child: SectionHeader(
                  title: 'Experience',
                  subtitle:
                      'My professional journey building impactful Flutter applications.',
                ),
              ),

              const SizedBox(height: 60),

              // Timeline
              ...List.generate(
                experienceList.length,
                (i) => AnimatedSection(
                  visibilityKey: 'exp-item-$i',
                  delay: Duration(milliseconds: i * 150),
                  child: _TimelineItem(
                    data: experienceList[i],
                    isDark: isDark,
                    isLast: i == experienceList.length - 1,
                    index: i,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatefulWidget {
  final ExperienceModel data;
  final bool isDark;
  final bool isLast;
  final int index;

  const _TimelineItem({
    required this.data,
    required this.isDark,
    required this.isLast,
    required this.index,
  });

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isCurrent = widget.data.isCurrent;

    return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Stack(clipBehavior: Clip.none, children: [
          // ── Connector line (full height of this item + padding) ──────
          if (!widget.isLast)
            Positioned(
              top: 36, // below the dot
              bottom: -32, // stretch through the padding to the next dot
              left: 19, // centre of the 40px left column
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.neonBlue.withValues(alpha: 0.40),
                      AppColors.neonBlue.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),

          // ── Main Content ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Timeline dot (adjusted width for mobile) ────────────────
              SizedBox(
                width: ResponsiveHelper.isMobile(context) ? 30 : 40,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isCurrent ? AppColors.neonGradient : null,
                        color: isCurrent ? null : AppColors.darkCardBorder,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.neonBlue
                                      .withValues(alpha: 0.50),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: ResponsiveHelper.isMobile(context) ? 12 : 20),

              // ── Content card ──────────────────────────────────────────
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: HoverGlassCard(
                    padding: ResponsiveHelper.isMobile(context)
                        ? const EdgeInsets.all(16)
                        : const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header row (responsive: Row on desktop, Column on mobile)
                        ResponsiveHelper.isMobile(context)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Role + current badge
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 10,
                                    children: [
                                      Text(
                                        widget.data.role,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: widget.isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      if (isCurrent)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.neonBlue
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppColors.neonBlue
                                                  .withValues(alpha: 0.40),
                                            ),
                                          ),
                                          child: const Text(
                                            'Current',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.neonBlue,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  MouseRegion(
                                    cursor:
                                        widget.data.companyWebsiteUrl != null
                                            ? SystemMouseCursors.click
                                            : SystemMouseCursors.basic,
                                    child: GestureDetector(
                                      onTap:
                                          widget.data.companyWebsiteUrl != null
                                              ? () async {
                                                  final uri = Uri.parse(widget
                                                      .data.companyWebsiteUrl!);
                                                  if (await canLaunchUrl(uri)) {
                                                    launchUrl(uri);
                                                  }
                                                }
                                              : null,
                                      child: Row(
                                        children: [
                                          if (widget.data.companyLogoUrl !=
                                                  null &&
                                              widget.data.companyLogoUrl!
                                                  .isNotEmpty) ...[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                widget.data.companyLogoUrl!,
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const SizedBox(),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Flexible(
                                            child: Text(
                                              widget.data.company,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.neonBlue,
                                                decoration: widget.data
                                                            .companyWebsiteUrl !=
                                                        null
                                                    ? TextDecoration.underline
                                                    : TextDecoration.none,
                                                decorationColor:
                                                    AppColors.neonBlue,
                                              ),
                                            ),
                                          ),
                                          if (widget.data.companyWebsiteUrl !=
                                              null) ...[
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.open_in_new,
                                              size: 12,
                                              color: AppColors.neonBlue,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Duration and location below on mobile
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      _InfoChip(
                                        icon: Icons.calendar_today_outlined,
                                        text: widget.data.duration,
                                        isDark: widget.isDark,
                                      ),
                                      _InfoChip(
                                        icon: Icons.location_on_outlined,
                                        text: widget.data.location,
                                        isDark: widget.isDark,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Role + current badge
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 10,
                                          children: [
                                            Text(
                                              widget.data.role,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: widget.isDark
                                                    ? AppColors.darkTextPrimary
                                                    : AppColors
                                                        .lightTextPrimary,
                                              ),
                                            ),
                                            if (isCurrent)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.neonBlue
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppColors.neonBlue
                                                        .withValues(
                                                            alpha: 0.40),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Current',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.neonBlue,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        MouseRegion(
                                          cursor:
                                              widget.data.companyWebsiteUrl !=
                                                      null
                                                  ? SystemMouseCursors.click
                                                  : SystemMouseCursors.basic,
                                          child: GestureDetector(
                                            onTap:
                                                widget.data.companyWebsiteUrl !=
                                                        null
                                                    ? () async {
                                                        final uri = Uri.parse(widget
                                                            .data
                                                            .companyWebsiteUrl!);
                                                        if (await canLaunchUrl(
                                                            uri)) {
                                                          launchUrl(uri);
                                                        }
                                                      }
                                                    : null,
                                            child: Row(
                                              children: [
                                                if (widget.data
                                                            .companyLogoUrl !=
                                                        null &&
                                                    widget.data.companyLogoUrl!
                                                        .isNotEmpty) ...[
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    child: Image.network(
                                                      widget
                                                          .data.companyLogoUrl!,
                                                      width: 20,
                                                      height: 20,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          const SizedBox(),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                Flexible(
                                                  child: Text(
                                                    widget.data.company,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.neonBlue,
                                                      decoration: widget.data
                                                                  .companyWebsiteUrl !=
                                                              null
                                                          ? TextDecoration
                                                              .underline
                                                          : TextDecoration.none,
                                                      decorationColor:
                                                          AppColors.neonBlue,
                                                    ),
                                                  ),
                                                ),
                                                if (widget.data
                                                        .companyWebsiteUrl !=
                                                    null) ...[
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.open_in_new,
                                                    size: 12,
                                                    color: AppColors.neonBlue,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _InfoChip(
                                        icon: Icons.calendar_today_outlined,
                                        text: widget.data.duration,
                                        isDark: widget.isDark,
                                      ),
                                      const SizedBox(height: 6),
                                      _InfoChip(
                                        icon: Icons.location_on_outlined,
                                        text: widget.data.location,
                                        isDark: widget.isDark,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.data.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tech tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.data.technologies
                              .map((tech) => _TechTag(
                                    label: tech,
                                    isDark: widget.isDark,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ])
            .animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.1, end: 0, duration: 600.ms));
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _TechTag extends StatelessWidget {
  final String label;
  final bool isDark;

  const _TechTag({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonBlue.withOpacity(0.25),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.neonBlue,
        ),
      ),
    );
  }
}
