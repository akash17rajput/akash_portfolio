import 'package:flutter/material.dart';

/// Responsive breakpoints and helper utilities
class ResponsiveHelper {
  ResponsiveHelper._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Returns value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? desktop;
    return desktop;
  }

  /// Horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) return 20;
    if (width < tabletBreakpoint) return 48;
    if (width < desktopBreakpoint) return 80;
    return (width - 1280) / 2 + 80;
  }

  /// Max content width
  static double maxContentWidth(BuildContext context) {
    return screenWidth(context).clamp(0, 1280);
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
          BuildContext context, bool isMobile, bool isTablet, bool isDesktop)
      builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      ResponsiveHelper.isMobile(context),
      ResponsiveHelper.isTablet(context),
      ResponsiveHelper.isDesktop(context),
    );
  }
}
