import 'package:cosmox_client_flutter/core/layout.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client_flutter/presentation/widgets/drawer.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DashboardShellPage extends StatefulWidget {
  final Widget child;
  const DashboardShellPage({super.key, required this.child});
  @override
  State<DashboardShellPage> createState() => _DashboardShellPageState();
}

class _DashboardShellPageState extends State<DashboardShellPage> {
  String _formatTitleFromRoute(BuildContext context) {
    const routeLabels = <String, String?>{
      '/home': null,
      '/dashboard': 'globalDashboard',
      '/dashboard/global/setting': 'globalSettings',
      '/dashboard/metadata/editor': 'metadataEditor',
      '/dashboard/usermanager': 'userManager',
      '/dashboard/librarymanager': 'library',
      '/dashboard/api/keys': 'apiManager',
      '/dashboard/network/setting': 'networkSettings',
      '/dashboard/plugin': 'pluginManager',
      '/dashboard/logs': 'logManager',
    };
    final location = GoRouterState.of(context).matchedLocation;
    // Exact match first
    for (final entry in routeLabels.entries) {
      if (location == entry.key) {
        return entry.value == null
            ? AppLocalizations.of(context)!.home
            : _localizedLabel(context, entry.value!);
      }
    }
    // Prefix match — pick the longest matching key
    String? bestKey;
    String? bestValue;
    int bestLength = 0;
    for (final entry in routeLabels.entries) {
      if (location.startsWith('${entry.key}/') &&
          entry.key.length > bestLength) {
        bestKey = entry.key;
        bestValue = entry.value;
        bestLength = entry.key.length;
      }
    }
    if (bestKey != null) {
      return bestValue == null
          ? AppLocalizations.of(context)!.home
          : _localizedLabel(context, bestValue);
    }
    return AppLocalizations.of(context)!.dashboard;
  }

  String _localizedLabel(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    return switch (key) {
      'globalDashboard' => loc.globalDashboard,
      'globalSettings' => loc.globalSettings,
      'metadataEditor' => loc.metadataEditor,
      'userManager' => loc.userManager,
      'library' => loc.library,
      'apiManager' => loc.apiManager,
      'networkSettings' => loc.networkSettings,
      'pluginManager' => loc.pluginManager,
      'logManager' => loc.logManager,
      _ => loc.dashboard,
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = _formatTitleFromRoute(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveBreakpoints.of(context).isMobile;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(title),
            leading: isMobile
                ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : null,
          ),
          drawer: isMobile ? const DashboardDrawerComponent() : null,
          body: Layout.main(
            context: context,
            leftDrawer: const DashboardDrawerComponent(),
            child: widget.child,
          ),
        );
      },
    );
  }
}
