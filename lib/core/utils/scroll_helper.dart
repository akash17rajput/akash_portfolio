import 'package:flutter/material.dart';

/// Global scroll controller and section key registry
class ScrollHelper {
  ScrollHelper._();

  static final ScrollController scrollController = ScrollController();

  // Global keys for each section
  static final Map<String, GlobalKey> sectionKeys = {
    'hero': GlobalKey(),
    'about': GlobalKey(),
    'skills': GlobalKey(),
    'experience': GlobalKey(),
    'projects': GlobalKey(),
    'contact': GlobalKey(),
  };

  /// Smooth scroll to a section by name
  static void scrollToSection(String section) {
    final key = sectionKeys[section];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  /// Get current scroll offset
  static double get currentOffset =>
      scrollController.hasClients ? scrollController.offset : 0;

  /// Dispose scroll controller
  static void dispose() {
    scrollController.dispose();
  }
}
