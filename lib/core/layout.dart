import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Layout {
  static Widget main({
    required BuildContext context,
    required Widget child,
    Widget? leftDrawer,
    Widget? navigationRail,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bp = ResponsiveBreakpoints.of(context);

        if (bp.isDesktop) {
          return _buildDesktopLayout(
            child: child,
            navigationRail: navigationRail,
            leftDrawer: leftDrawer,
          );
        } else if (bp.isTablet) {
          return _buildTabletLayout(
            child: child,
            navigationRail: navigationRail,
            leftDrawer: leftDrawer,
          );
        } else {
          return _buildMobileLayout(child: child, leftDrawer: leftDrawer);
        }
      },
    );
  }

  static Widget _buildDesktopLayout({
    required Widget child,
    Widget? navigationRail,
    Widget? leftDrawer,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (navigationRail != null)
          navigationRail
        else if (leftDrawer != null)
          SizedBox(width: 250, child: leftDrawer),
        Expanded(child: child),
      ],
    );
  }

  static Widget _buildTabletLayout({
    required Widget child,
    Widget? navigationRail,
    Widget? leftDrawer,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (navigationRail != null)
          navigationRail
        else if (leftDrawer != null)
          SizedBox(width: 200, child: leftDrawer),
        Expanded(child: child),
      ],
    );
  }

  static Widget _buildMobileLayout({
    required Widget child,
    Widget? leftDrawer,
  }) {
    return child;
  }

  static Widget adaptiveColumn({
    required BuildContext context,
    required List<Widget> children,
    double? mobileColumns,
    double? tabletColumns,
    double? desktopColumns,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bp = ResponsiveBreakpoints.of(context);
        final int columns;

        if (bp.isMobile) {
          columns = (mobileColumns ?? 1).toInt();
        } else if (bp.isTablet) {
          columns = (tabletColumns ?? 2).toInt();
        } else {
          columns = (desktopColumns ?? 3).toInt();
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children.map((child) {
            return SizedBox(
              width: (width - (columns - 1) * 16) / columns,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }

  static Widget adaptiveCenter({
    required BuildContext context,
    required Widget child,
    double mobileWidth = double.infinity,
    double tabletWidth = 800,
    double desktopWidth = 1200,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bp = ResponsiveBreakpoints.of(context);
        double contentWidth;

        if (bp.isMobile) {
          contentWidth = mobileWidth;
        } else if (bp.isTablet) {
          contentWidth = tabletWidth;
        } else {
          contentWidth = desktopWidth;
        }

        if (contentWidth == double.infinity || width <= contentWidth) {
          return child;
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: child,
          ),
        );
      },
    );
  }
}
