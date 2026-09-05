import 'package:flutter/material.dart';

/// Device type classification based on width breakpoints.
enum DeviceType {
  phone,
  tablet,
  largeTablet,
}

/// Centralized responsive utility and breakpoint manager for Ayo Vaani.
///
/// Breakpoints:
/// - [phone]: width < 600dp
/// - [tablet]: 600dp <= width < 900dp (e.g., Samsung Galaxy Tab A7 Lite portrait)
/// - [largeTablet]: width >= 900dp (e.g., Samsung Galaxy Tab A7 Lite landscape, large tablets)
abstract final class Responsive {
  /// Maximum width for phone layout in dp.
  static const double phoneBreakpoint = 600.0;

  /// Maximum width for standard tablet layout in dp.
  static const double tabletBreakpoint = 900.0;

  /// Default max content width to maintain clean editorial layout on wide screens.
  static const double maxContentWidth = 1200.0;

  /// Get current [DeviceType] from [BuildContext].
  static DeviceType deviceTypeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < phoneBreakpoint) {
      return DeviceType.phone;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.largeTablet;
    }
  }

  /// Whether current screen width corresponds to a phone (< 600dp).
  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phoneBreakpoint;

  /// Whether current screen width corresponds to a tablet (600dp - 899dp).
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= phoneBreakpoint && width < tabletBreakpoint;
  }

  /// Whether current screen width corresponds to a large tablet / landscape tablet (>= 900dp).
  static bool isLargeTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Whether current screen is a tablet or large tablet (>= 600dp).
  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= phoneBreakpoint;

  /// Whether current device orientation is landscape.
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Selects a responsive value based on current device screen size.
  static T value<T>({
    required BuildContext context,
    required T phone,
    T? tablet,
    T? largeTablet,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint && largeTablet != null) {
      return largeTablet;
    }
    if (width >= phoneBreakpoint && tablet != null) {
      return tablet;
    }
    return phone;
  }

  /// Standard responsive horizontal padding.
  static EdgeInsets screenPadding(BuildContext context) {
    final horizontal = value<double>(
      context: context,
      phone: 16.0,
      tablet: 24.0,
      largeTablet: 32.0,
    );
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16.0);
  }

  /// Standard grid column count based on available screen width.
  static int gridColumns(BuildContext context) {
    return value<int>(
      context: context,
      phone: 1,
      tablet: 2,
      largeTablet: 3,
    );
  }
}

/// A widget that renders different layouts based on screen breakpoints.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.phone,
    this.tablet,
    this.largeTablet,
  });

  /// Widget to render on phone screens (< 600dp).
  final Widget phone;

  /// Optional widget for tablet screens (600dp - 899dp).
  /// If null, falls back to [phone].
  final Widget? tablet;

  /// Optional widget for large tablet / desktop screens (>= 900dp).
  /// If null, falls back to [tablet] or [phone].
  final Widget? largeTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Responsive.tabletBreakpoint &&
            largeTablet != null) {
          return largeTablet!;
        }
        if (constraints.maxWidth >= Responsive.phoneBreakpoint &&
            tablet != null) {
          return tablet!;
        }
        return phone;
      },
    );
  }
}

/// A container that constrains content to a readable maximum width
/// on wide tablet/landscape displays, centering the content cleanly.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
