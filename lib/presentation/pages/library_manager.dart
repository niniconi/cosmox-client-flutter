import 'package:cosmox_client_flutter/core/global_keys.dart';
import 'package:cosmox_client_flutter/presentation/widgets/add_library.dart';
import 'package:cosmox_client_flutter/presentation/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LibraryManagerPage extends StatefulWidget {
  const LibraryManagerPage({super.key});

  @override
  State<LibraryManagerPage> createState() => _LibraryManagerPageState();
}

class _LibraryManagerPageState extends State<LibraryManagerPage> {
  final Logger _logger = Logger('LibraryManagerPage');
  double minCardWidth = 300;
  bool loaded = false;
  List<Widget> libraryCards = [];

  void _fetchLibraries() async {
    try {
      final libs = await SdkProxy.instance.libraryQuery();
      setState(() {
        loaded = true;
        libraryCards = libs.map((x) => _buildLibraryCard(x)).toList();
      });
    } catch (error) {
      _logger.severe("Failed fetch libraries from server", error);
    }
  }

  void _scanLibrary(BigInt lid) async {
    try {
      final result = await SdkProxy.instance.scannerScan(lid: lid);
      _logger.fine(result);
    } catch (error) {
      _logger.severe("Failed to scan library", error);
    }
  }

  Future<void> _deleteLibrary(Library lib) async {
    try {
      await SdkProxy.instance.libraryDelete(lid: lib.lid);
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to delete library: $error")),
      );
      return;
    }

    _fetchLibraries();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text("Deleted library ${lib.name ?? ''}")),
    );
  }

  Widget _buildLibraryCard(Library lib) {
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              const SizedBox(height: 200 + 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lib.name ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(lib.description ?? ""),
                    ],
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(onTap: null, child: const Text('Edit')),
                        PopupMenuItem(
                          child: const Text('Scan'),
                          onTap: () => _scanLibrary(lib.lid),
                        ),
                        PopupMenuItem(
                          child: const Text('Delete'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => DialogProvider.alert(
                                context,
                                title: 'Delete this',
                                content: [
                                  AppLocalizations.of(
                                    context,
                                  )!.areYouSureDeleteThisUser,
                                ],
                                confirmAction: () {
                                  _deleteLibrary(lib);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
                      ];
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            image: const DecorationImage(
              image: AssetImage('assets/images/placeholder.jpg'),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchLibraries();
  }

  @override
  Widget build(BuildContext context) {
    Widget main = const Center(child: CircularProgressIndicator());
    if (loaded) {
      if (libraryCards.isEmpty) {
        main = const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Empty', style: TextStyle(fontSize: 48)),
              Icon(Icons.add_box, size: 48),
            ],
          ),
        );
      } else {
        main = SingleChildScrollView(
          child: Container(
            width: ResponsiveBreakpoints.of(context).screenWidth,
            alignment: Alignment.center,
            child: Wrap(
              children: List.generate(libraryCards.length, (index) {
                return SizedBox(
                  height: 300,
                  width: 400,
                  child: libraryCards[index],
                );
              }),
            ),
          ),
        );
      }
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add library',
        onPressed: () async {
          final added = await showDialog<bool>(
            context: context,
            builder: (context) {
              final bp = ResponsiveBreakpoints.of(context);
              if (bp.screenWidth < 1200 || bp.screenHeight < 900) {
                return const Dialog(child: AddLibraryComponent());
              } else {
                return const Dialog(child: AddLibraryComponent());
              }
            },
          );
          if (added == true) {
            _fetchLibraries();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: main,
    );
  }
}
