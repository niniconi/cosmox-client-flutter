import 'package:flutter/material.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';

class NavigationRouteInfo {
  final String label;
  final Icon icon;
  final Icon selectedIcon;
  final String route;
  NavigationRouteInfo({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

/// Derive the flat [NavigationDrawer] index from the current GoRouter location
/// by matching against a list of [NavigationRouteInfo]s.
///
/// Returns `null` when no route matches (e.g. the user is on a page not
/// represented in the drawer), which leaves the drawer with no highlight.
int? _routeIndexFromLocation(
  String location,
  List<NavigationRouteInfo> routes,
) {
  // First pass: exact match (more specific routes)
  for (int i = 0; i < routes.length; i++) {
    if (location == routes[i].route) return i;
  }
  // Second pass: prefix match — pick the LONGEST matching prefix so that
  // e.g. /dashboard does not swallow /dashboard/usermanager
  int? bestIndex;
  int bestLength = 0;
  for (int i = 0; i < routes.length; i++) {
    final route = routes[i].route;
    if (location.startsWith('$route/') && route.length > bestLength) {
      bestIndex = i;
      bestLength = route.length;
    }
  }
  return bestIndex;
}

class HomeDrawerComponent extends StatefulWidget {
  const HomeDrawerComponent({super.key});

  @override
  State<HomeDrawerComponent> createState() => _HomeDrawerComponentState();
}

class _HomeDrawerComponentState extends State<HomeDrawerComponent> {
  final Logger _logger = Logger('HomeDrawerComponent');
  List<NavigationRouteInfo> libraryRoutes = [];

  /// fetch library list from server
  void _fetchLibraryRouteInfos() async {
    try {
      final libs = await SdkProxy.instance.libraryQuery();
      _logger.fine('Library routes loaded: ${libs.length}');
      setState(() {
        libraryRoutes = libs
            .map(
              (lib) => NavigationRouteInfo(
                label: lib.name ?? "Unknown",
                icon: const Icon(Icons.movie_outlined),
                selectedIcon: const Icon(Icons.movie),
                route: "/library/view/${lib.lid}",
              ),
            )
            .toList();
      });
    } catch (error) {
      _logger.severe('Failed to fetch library routes', error);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLibraryRouteInfos();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final homeRoutes = _buildHomeRoutes();
    final allRoutes = [...homeRoutes, ...libraryRoutes];
    final selectedIndex = _routeIndexFromLocation(location, allRoutes);

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      children: [
        const DrawerHeader(child: Icon(Icons.home, size: 48)),
        Padding(
          padding: const EdgeInsets.only(
            left: 28,
            top: 16,
            bottom: 16,
            right: 20,
          ),
          child: Text(
            AppLocalizations.of(context)!.home,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...homeRoutes.map((element) {
          return NavigationDrawerDestination(
            icon: element.icon,
            label: Text(element.label),
            selectedIcon: element.selectedIcon,
          );
        }),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(
            left: 28,
            top: 16,
            bottom: 16,
            right: 20,
          ),
          child: Text(
            AppLocalizations.of(context)!.library,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...libraryRoutes.map((element) {
          return NavigationDrawerDestination(
            icon: element.icon,
            label: Text(element.label),
            selectedIcon: element.selectedIcon,
          );
        }),
      ],
      onDestinationSelected: (index) {
        if (index < homeRoutes.length) {
          context.go(homeRoutes[index].route);
        } else {
          context.push(libraryRoutes[index - homeRoutes.length].route);
        }
      },
    );
  }

  List<NavigationRouteInfo> _buildHomeRoutes() {
    return [
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.home,
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        route: "/home",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.globalDashboard,
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.home),
        route: "/dashboard",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.settings,
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.home),
        route: "/client/setting",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.logout,
        icon: const Icon(Icons.logout_outlined),
        selectedIcon: const Icon(Icons.logout),
        route: "/logout",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.about,
        icon: const Icon(Icons.info_outline),
        selectedIcon: const Icon(Icons.home),
        route: "/about",
      ),
    ];
  }
}

class DashboardDrawerComponent extends StatefulWidget {
  const DashboardDrawerComponent({super.key});
  @override
  State<DashboardDrawerComponent> createState() =>
      _DashboardDrawerComponentState();
}

class _DashboardDrawerComponentState extends State<DashboardDrawerComponent> {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final dashboardRoutes = _buildDashboardRoutes(context);
    final advancedRoutes = _buildAdvancedRoutes(context);
    final otherRoutes = _buildOtherRoutes(context);

    // Merge all routes into one flat list so that prefix matching works
    // across groups — /dashboard/api/keys must match against advancedRoutes,
    // not be swallowed by /dashboard in dashboardRoutes.
    final allRoutes = [...dashboardRoutes, ...advancedRoutes, ...otherRoutes];
    final flatIndex = _routeIndexFromLocation(location, allRoutes);

    return NavigationDrawer(
      selectedIndex: flatIndex,
      children: [
        const DrawerHeader(child: Icon(Icons.dashboard, size: 48)),
        Padding(
          padding: const EdgeInsets.only(
            left: 28,
            top: 16,
            bottom: 16,
            right: 20,
          ),
          child: Text(
            AppLocalizations.of(context)!.dashboard,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...dashboardRoutes.map((element) {
          return NavigationDrawerDestination(
            icon: element.icon,
            label: Text(element.label),
            selectedIcon: element.selectedIcon,
          );
        }),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(
            left: 28,
            top: 16,
            bottom: 16,
            right: 20,
          ),
          child: Text(
            AppLocalizations.of(context)!.advanced,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...advancedRoutes.map((element) {
          return NavigationDrawerDestination(
            icon: element.icon,
            label: Text(element.label),
            selectedIcon: element.selectedIcon,
          );
        }),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(
            left: 28,
            top: 16,
            bottom: 16,
            right: 20,
          ),
          child: Text(
            AppLocalizations.of(context)!.about,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...otherRoutes.map((element) {
          return NavigationDrawerDestination(
            icon: element.icon,
            label: Text(element.label),
            selectedIcon: element.selectedIcon,
          );
        }),
      ],
      onDestinationSelected: (index) {
        NavigationRouteInfo routeInfo;
        if (index < dashboardRoutes.length) {
          routeInfo = dashboardRoutes[index];
        } else if (index - dashboardRoutes.length < advancedRoutes.length) {
          routeInfo = advancedRoutes[index - dashboardRoutes.length];
        } else {
          routeInfo =
              otherRoutes[index -
                  advancedRoutes.length -
                  dashboardRoutes.length];
        }
        context.go(routeInfo.route);
      },
    );
  }

  List<NavigationRouteInfo> _buildDashboardRoutes(BuildContext context) {
    return [
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.home,
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        route: "/home",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.globalDashboard,
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        route: "/dashboard",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.globalSettings,
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        route: "/dashboard/global/setting",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.metadataEditor,
        icon: const Icon(Icons.phone_outlined),
        selectedIcon: const Icon(Icons.phone_rounded),
        route: "/dashboard/metadata/editor",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.userManager,
        icon: const Icon(Icons.account_circle_outlined),
        selectedIcon: const Icon(Icons.account_circle),
        route: "/dashboard/usermanager",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.library,
        icon: const Icon(Icons.movie_outlined),
        selectedIcon: const Icon(Icons.movie),
        route: "/dashboard/librarymanager",
      ),
    ];
  }

  List<NavigationRouteInfo> _buildAdvancedRoutes(BuildContext context) {
    return [
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.apiManager,
        icon: const Icon(Icons.key_outlined),
        selectedIcon: const Icon(Icons.key),
        route: "/dashboard/api/keys",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.networkSettings,
        icon: const Icon(Icons.account_tree_outlined),
        selectedIcon: const Icon(Icons.account_tree),
        route: "/dashboard/network/setting",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.pluginManager,
        icon: const Icon(Icons.extension_outlined),
        selectedIcon: const Icon(Icons.extension),
        route: "/dashboard/plugin",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.logManager,
        icon: const Icon(Icons.note_outlined),
        selectedIcon: const Icon(Icons.note),
        route: "/dashboard/logs",
      ),
    ];
  }

  List<NavigationRouteInfo> _buildOtherRoutes(BuildContext context) {
    return [
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.logout,
        icon: const Icon(Icons.logout_outlined),
        selectedIcon: const Icon(Icons.logout),
        route: "/logout",
      ),
      NavigationRouteInfo(
        label: AppLocalizations.of(context)!.about,
        icon: const Icon(Icons.info_outline),
        selectedIcon: const Icon(Icons.info),
        route: "/about",
      ),
    ];
  }
}
