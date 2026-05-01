import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/contact_provider.dart';
import '../shared/animated_section.dart';
import '../shared/glass_card.dart';
import '../shared/gradient_button.dart';
import '../shared/section_header.dart';

/// Contact section with Firebase-backed form and social links
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

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
                visibilityKey: 'contact-header',
                child: SectionHeader(
                  title: 'Get In Touch',
                  subtitle:
                      'Have a project in mind? Let\'s build something amazing together.',
                ),
              ),
              const SizedBox(height: 60),
              isMobile
                  ? Column(
                      children: [
                        _ContactInfo(isDark: isDark),
                        const SizedBox(height: 32),
                        _ContactForm(isDark: isDark),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: AnimatedSection(
                            visibilityKey: 'contact-info',
                            child: _ContactInfo(isDark: isDark),
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 6,
                          child: AnimatedSection(
                            visibilityKey: 'contact-form',
                            delay: const Duration(milliseconds: 200),
                            child: _ContactForm(isDark: isDark),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final bool isDark;
  const _ContactInfo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final contactItems = [
      {
        'icon': Icons.email_outlined,
        'label': 'Email',
        'value': AppConstants.developerEmail,
        'url': 'mailto:${AppConstants.developerEmail}',
      },
      {
        'icon': Icons.phone_outlined,
        'label': 'Phone',
        'value': AppConstants.developerPhone,
        'url': 'tel:${AppConstants.developerPhone}',
      },
      {
        'icon': Icons.location_on_outlined,
        'label': 'Location',
        'value': AppConstants.developerLocation,
        'url': null,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Let\'s Connect',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'I\'m always open to discussing new projects, creative ideas, or opportunities to be part of your vision.',
          style: TextStyle(
            fontSize: 15,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),

        // Contact items
        ...contactItems.map((item) => _ContactItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              value: item['value'] as String,
              url: item['url'] as String?,
              isDark: isDark,
            )),

        const SizedBox(height: 32),

        // Social links
        Text(
          'Follow Me',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            _SocialButton(
              icon: Icons.code,
              label: 'GitHub',
              url: AppConstants.githubUrl,
            ),
            SizedBox(width: 12),
            _SocialButton(
              icon: Icons.work_outline,
              label: 'LinkedIn',
              url: AppConstants.linkedinUrl,
            ),
            // SizedBox(width: 12),
            // _SocialButton(
            //   icon: Icons.alternate_email,
            //   label: 'Twitter',
            //   url: AppConstants.twitterUrl,
            // ),
          ],
        ),
      ],
    );
  }
}

class _ContactItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? url;
  final bool isDark;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.url,
    required this.isDark,
  });

  @override
  State<_ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<_ContactItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.url != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.url != null
            ? () async {
                final uri = Uri.parse(widget.url!);
                if (await canLaunchUrl(uri)) launchUrl(uri);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.neonBlue.withOpacity(0.15)
                      : AppColors.neonBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovered
                        ? AppColors.neonBlue.withOpacity(0.5)
                        : AppColors.neonBlue.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: AppColors.neonBlue,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _isHovered
                          ? AppColors.neonBlue
                          : (widget.isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String url;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: _isHovered ? AppColors.neonGradient : null,
            color: _isHovered ? null : AppColors.neonBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? Colors.transparent
                  : AppColors.neonBlue.withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _isHovered ? Colors.white : AppColors.neonBlue,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _isHovered ? Colors.white : AppColors.neonBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contact form with Firebase submission
class _ContactForm extends StatefulWidget {
  final bool isDark;
  const _ContactForm({required this.isDark});

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ContactProvider>();
    await provider.submitMessage(
      name: _nameController.text,
      email: _emailController.text,
      message: _messageController.text,
    );

    if (!mounted) return;

    if (provider.status == ContactStatus.success) {
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Message sent successfully! I\'ll get back to you soon.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      provider.reset();
    } else if (provider.status == ContactStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                provider.errorMessage ?? 'Something went wrong.',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a Message',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: widget.isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            _FormField(
              controller: _nameController,
              label: 'Your Name',
              hint: 'John Doe',
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Email field
            _FormField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'john@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Message field
            _FormField(
              controller: _messageController,
              label: 'Message',
              hint: 'Tell me about your project...',
              icon: Icons.message_outlined,
              maxLines: 5,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Message is required';
                if (v.trim().length < 10) {
                  return 'Message must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit button
            Consumer<ContactProvider>(
              builder: (context, provider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.neonBlue,
                          ),
                        )
                      : GradientButton(
                          label: 'Send Message',
                          icon: Icons.send_outlined,
                          onPressed: _submit,
                          width: double.infinity,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 200.ms);
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.neonBlue),
      ),
    );
  }
}
