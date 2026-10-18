import 'package:cosmox_client_flutter/core/global_keys.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Logger _logger = Logger('HomePage');

  List<Library> _libraries = [];
  int _selectedIndex = 0;

  void _fetchLibraries() async {
    try {
      final libs = await SdkProxy.instance.libraryQuery();
      _logger.fine('Libraries loaded: ${libs.length}');
      if (!mounted) return;
      setState(() => _libraries = libs);
    } catch (error) {
      _logger.severe('Failed to fetch libraries', error);
      if (!mounted) return;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to fetch libraries: $error')),
      );
    }
  }

  ImageProvider _getLibraryCover(int index) {
    return const AssetImage("assets/images/placeholder.jpg");
  }

  @override
  void initState() {
    super.initState();
    _fetchLibraries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.message_outlined),
            selectedIcon: const Icon(Icons.message),
            label: AppLocalizations.of(context)!.messages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.mine,
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: TabBarView(
        children: [
          RefreshIndicator(
            color: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 1;
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                        onPressed: null,
                        child: const Text("Library >"),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(height: 150),
                      child: CarouselView(
                        itemSnapping: true,
                        itemExtent: 180,
                        shrinkExtent: 100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        onTap: (index) {
                          _logger.fine(
                            "route to /library/view/${_libraries[index].lid}",
                          );
                          context.push(
                            "/library/view/${_libraries[index].lid}",
                          );
                        },
                        children: List.generate(_libraries.length, (index) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: _getLibraryCover(index),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                /*libraries[index].title ??*/ "Undefined name",
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 70),
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                        onPressed: null,
                        child: Text(AppLocalizations.of(context)!.newUpdate),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(height: 150),
                      child: CarouselView(
                        itemSnapping: true,
                        itemExtent: 180,
                        shrinkExtent: 100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        children: List.generate(_libraries.length, (index) {
                          return Center(
                            child: Text(
                              /*libraries[index].title ??*/ "Undefined name",
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Text("a"),
          const Text("b"),
        ],
      ),
    );
  }
}
