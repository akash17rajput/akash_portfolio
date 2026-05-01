import 'package:flutter/material.dart';
import '../core/utils/scroll_helper.dart';

/// Provider for managing navbar state (active section, scroll position)
class NavProvider extends ChangeNotifier {
  String _activeSection = 'hero';
  bool _isScrolled = false;
  bool _isMobileMenuOpen = false;

  String get activeSection => _activeSection;
  bool get isScrolled => _isScrolled;
  bool get isMobileMenuOpen => _isMobileMenuOpen;

  NavProvider() {
    ScrollHelper.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = ScrollHelper.scrollController.offset;

    // Update scroll state for navbar background
    final wasScrolled = _isScrolled;
    _isScrolled = offset > 80;

    // Determine active section based on scroll position
    String newSection = _activeSection;
    for (final entry in ScrollHelper.sectionKeys.entries) {
      final context = entry.value.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          if (position.dy <= 120 && position.dy > -box.size.height + 120) {
            newSection = entry.key;
          }
        }
      }
    }

    if (wasScrolled != _isScrolled || newSection != _activeSection) {
      _activeSection = newSection;
      notifyListeners();
    }
  }

  void setActiveSection(String section) {
    _activeSection = section;
    notifyListeners();
    ScrollHelper.scrollToSection(section);
  }

  void toggleMobileMenu() {
    _isMobileMenuOpen = !_isMobileMenuOpen;
    notifyListeners();
  }

  void closeMobileMenu() {
    _isMobileMenuOpen = false;
    notifyListeners();
  }

  @override
  void dispose() {
    ScrollHelper.scrollController.removeListener(_onScroll);
    super.dispose();
  }
}
