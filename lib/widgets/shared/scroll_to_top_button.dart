import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/scroll_helper.dart';
import '../../core/theme/app_theme.dart';

class ScrollToTopButton extends StatefulWidget {
  const ScrollToTopButton({super.key});

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    ScrollHelper.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (ScrollHelper.scrollController.hasClients) {
      final offset = ScrollHelper.scrollController.offset;
      if (offset > 400 && !_isVisible) {
        setState(() => _isVisible = true);
      } else if (offset <= 400 && _isVisible) {
        setState(() => _isVisible = false);
      }
    }
  }

  @override
  void dispose() {
    ScrollHelper.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      bottom: _isVisible ? 32.0 : -80.0,
      right: 32.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isVisible ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: () {
            if (ScrollHelper.scrollController.hasClients) {
              ScrollHelper.scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
              );
            }
          },
          backgroundColor: AppColors.neonBlue,
          foregroundColor: Colors.white,
          elevation: 8,
          child: const Icon(Icons.arrow_upward_rounded),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(
                begin: -4, end: 4, duration: 1200.ms, curve: Curves.easeInOut)
            .boxShadow(
              begin: BoxShadow(
                color: AppColors.neonBlue.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              end: BoxShadow(
                color: AppColors.neonBlue.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 3,
              ),
              duration: 1200.ms,
            ),
      ),
    );
  }
}
