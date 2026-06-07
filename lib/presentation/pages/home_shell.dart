import 'package:cosmox_client/core/state.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client/presentation/widgets/drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';

class HomeShellPage extends StatefulWidget {
  final Widget child;
  const HomeShellPage({super.key, required this.child});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Cosmox"),
          actions: [
            IconButton(
              onPressed: () => context.push("/search"),
              icon: const Icon(Icons.search_rounded),
            ),
            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  onPressed: () => context.push(
                    "/user/${context.read<AuthController>().uid}",
                  ),
                  child: Text(AppLocalizations.of(context)!.account),
                ),
              ],
              builder: (context, controller, child) {
                return IconButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Icons.account_circle_outlined),
                );
              },
            ),
          ],
        ),
        drawer: const HomeDrawerComponent(),
        body: Row(
          children: [
            /*
              NavigationRail(
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home),
                      label: Text(AppLocalizations.of(context)!.home),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.message_outlined),
                      selectedIcon: Icon(Icons.message),
                      label: Text(AppLocalizations.of(context)!.messages),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text(AppLocalizations.of(context)!.mine),
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  }),
                  */
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
