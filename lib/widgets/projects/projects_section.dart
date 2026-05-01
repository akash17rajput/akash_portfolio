import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/project_model.dart';
import '../../providers/projects_provider.dart';
import '../shared/animated_section.dart';
import '../shared/hover_animated_card.dart';
import '../shared/section_header.dart';

/// Projects section with Firebase-powered dynamic cards and category filter
class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                visibilityKey: 'projects-header',
                child: SectionHeader(
                  title: 'Projects',
                  subtitle:
                      'A showcase of my work — from mobile apps to web platforms.',
                ),
              ),

              const SizedBox(height: 40),

              // Category filter
              AnimatedSection(
                visibilityKey: 'projects-filter',
                delay: const Duration(milliseconds: 200),
                child: _CategoryFilter(isDark: isDark),
              ),

              const SizedBox(height: 40),

              // Projects grid
              Consumer<ProjectsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const _LoadingGrid();
                  }

                  final projects = provider.filteredProjects;

                  if (projects.isEmpty) {
                    return _EmptyState(isDark: isDark);
                  }

                  return _ProjectsGrid(
                    projects: projects,
                    isDark: isDark,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category filter ─────────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  final bool isDark;
  const _CategoryFilter({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AppConstants.projectCategories.map((category) {
              final isSelected = provider.selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _FilterChip(
                  label: category,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => provider.setCategory(category),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppColors.neonGradient : null,
            color: widget.isSelected
                ? null
                : (_isHovered
                    ? AppColors.neonBlue.withValues(alpha: 0.10)
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04))),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : (_isHovered
                      ? AppColors.neonBlue.withValues(alpha: 0.50)
                      : (widget.isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.black.withValues(alpha: 0.10))),
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.neonBlue.withValues(alpha: 0.30),
                      blurRadius: 15,
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              color: widget.isSelected
                  ? Colors.white
                  : (_isHovered
                      ? AppColors.neonBlue
                      : (widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Projects grid ────────────────────────────────────────────────────────────

class _ProjectsGrid extends StatelessWidget {
  final List<ProjectModel> projects;
  final bool isDark;

  const _ProjectsGrid({required this.projects, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: isMobile ? 1 : 0.85,
      ),
      itemCount: projects.length,
      itemBuilder: (context, i) {
        return AnimatedSection(
          visibilityKey: 'project-card-$i',
          delay: Duration(milliseconds: i * 100),
          child: _ProjectCard(
            project: projects[i],
            isDark: isDark,
          ),
        );
      },
    );
  }
}

// ─── Project card with HoverAnimatedCard ─────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final bool isDark;

  const _ProjectCard({required this.project, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return HoverAnimatedCard(
      borderRadius: 20,
      padding: EdgeInsets.zero, // we handle padding inside
      particleCount: 12,
      onTap: () async {
        final uri = Uri.parse(project.liveUrl);
        if (await canLaunchUrl(uri)) launchUrl(uri);
      },
      child: _ProjectCardContent(project: project, isDark: isDark),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 500.ms,
        );
  }
}

class _ProjectCardContent extends StatelessWidget {
  final ProjectModel project;
  final bool isDark;

  const _ProjectCardContent({
    required this.project,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project image — takes upper portion
        Expanded(
          flex: isMobile ? 3 : 5,
          child: _ProjectImage(imageUrl: project.imageUrl),
        ),

        // Project info
        Expanded(
          flex: isMobile ? 10 : 6,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neonBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.neonBlue.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Text(
                    project.category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neonBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  project.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Description
                Flexible(
                  child: Text(
                    project.description,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                    maxLines: isMobile ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 10),

                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: project.tags
                      .take(isMobile ? 2 : 3)
                      .map((tag) => _TagChip(label: tag, isDark: isDark))
                      .toList(),
                ),

                const SizedBox(height: 12),

                // View button
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.neonBlue.withValues(alpha: 0.40),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new,
                              size: 14, color: AppColors.neonBlue),
                          SizedBox(width: 6),
                          Text(
                            'View',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neonBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectImage extends StatelessWidget {
  final String imageUrl;
  const _ProjectImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: isDark
                    ? AppColors.darkCard
                    : AppColors.lightCardBorder.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonBlue,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => const _PlaceholderImage(),
            )
          : const _PlaceholderImage(),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0D1526), Color(0xFF1A2540)]
              : [Colors.grey.shade200, Colors.grey.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.code,
          size: 48,
          color: AppColors.neonBlue.withValues(alpha: 0.30),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _TagChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, i) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: _animation.value * 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonBlue.withValues(alpha: 0.10),
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: AppColors.neonBlue.withValues(alpha: 0.30),
          ),
          const SizedBox(height: 16),
          Text(
            'No projects in this category yet.',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
