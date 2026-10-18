import 'package:cosmox_client_flutter/core/global_keys.dart';
import 'package:cosmox_client_flutter/presentation/widgets/form.dart';
import 'package:cosmox_client_flutter/presentation/widgets/path_selector.dart';
import 'package:cosmox_client_flutter/core/common.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    as frb;
import 'package:responsive_framework/responsive_framework.dart';

class AddLibraryComponent extends StatefulWidget {
  const AddLibraryComponent({super.key});

  @override
  State<AddLibraryComponent> createState() => _AddLibraryComponentState();
}

class _AddLibraryComponentState extends State<AddLibraryComponent> {
  final Logger _logger = Logger('AddLibraryComponent');
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _pathsController;
  final Map<String, dynamic> payload = {
    "library_paths": <String>[''],
    'tags': <int>[],
  };

  List<LibraryType> _libraryTypes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pathsController = [TextEditingController()];
    _fetchLibraryTypes();
  }

  @override
  void dispose() {
    for (final controller in _pathsController) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchLibraryTypes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final types = await SdkProxy.instance.libraryTypes();
      if (!mounted) return;
      setState(() {
        _libraryTypes = types;
        if (types.isNotEmpty) {
          payload["type"] = types.first.tid;
        }
        _isLoading = false;
      });
    } catch (error) {
      _logger.severe('Failed fetch library types', error);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<bool> _addLibrary() async {
    _logger.fine(payload);
    try {
      await SdkProxy.instance.libraryAdd(
        name: payload["name"] ?? "",
        description: payload["description"] as String?,
        typeId: payload["type"] as BigInt? ?? BigInt.zero,
        tags: frb.Uint64List.fromList(List<int>.from(payload["tags"] ?? [])),
        libraryPaths: List<String>.from(payload["library_paths"] ?? []),
      );
      return true;
    } catch (error) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to add library: $error")),
      );
      return false;
    }
  }

  void _updateLibraryPaths(int index, String value) {
    setState(() {
      payload["library_paths"][index] = value;
      _pathsController[index].text = value;
    });
  }

  List<DropdownMenuEntry<BigInt>> _buildDropdownEntries() {
    return _libraryTypes.map((e) {
      return DropdownMenuEntry<BigInt>(value: e.tid, label: e.label);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Loading state while fetching library types
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(loc.loading, style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              loc.failed,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: _fetchLibraryTypes,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Ready state — show the form
    final dropdownEntries = _buildDropdownEntries();

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //  Dialog header
              Row(
                children: [
                  Icon(Icons.add, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    '${loc.add} ${loc.library}',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              //  Library type
              DropdownMenu<BigInt>(
                expandedInsets: EdgeInsets.zero,
                initialSelection: dropdownEntries.isNotEmpty
                    ? dropdownEntries[0].value
                    : null,
                dropdownMenuEntries: dropdownEntries,
                label: const Text('Library type'),
                leadingIcon: Icon(
                  Icons.category,
                  color: theme.colorScheme.primary,
                ),
                onSelected: (tid) {
                  if (tid != null) {
                    _logger.fine(tid);
                    payload["type"] = tid;
                  }
                },
              ),
              const SizedBox(height: 16),

              //  Name
              InputFormField(
                labelText: 'Name',
                onSaved: (val) => payload["name"] = val,
              ),
              const SizedBox(height: 16),

              //  Description
              InputFormField(
                maxLines: 6,
                labelText: loc.description,
                onSaved: (val) {
                  payload["description"] = val;
                },
              ),
              const SizedBox(height: 20),

              //  Library paths
              Text(
                'Library Paths',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(payload["library_paths"].length + 1, (index) {
                if (index < payload["library_paths"].length) {
                  _logger.fine(
                    'drawing list with ${payload["library_paths"][index]}',
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: InputFormField(
                            labelText: 'Path',
                            controller: _pathsController[index],
                            validator: (val) => Validate.path(val),
                            onSaved: (val) =>
                                payload["library_paths"][index] = val,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) {
                              final component = PathSelectorComponent(
                                then: (path) =>
                                    _updateLibraryPaths(index, path),
                              );

                              final bp = ResponsiveBreakpoints.of(context);
                              if (bp.screenWidth < 1200 ||
                                  bp.screenHeight < 900) {
                                return Dialog.fullscreen(child: component);
                              } else {
                                return Dialog(child: component);
                              }
                            },
                          ),
                          icon: const Icon(Icons.folder_open),
                          tooltip: 'Browse',
                        ),
                      ],
                    ),
                  );
                } else {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _formKey.currentState!.save();
                        setState(() {
                          payload["library_paths"].add("");
                          _pathsController.add(
                            TextEditingController(
                              text: payload["library_paths"][index],
                            ),
                          );
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add path'),
                    ),
                  );
                }
              }),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: Text(loc.close),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final ok = await _addLibrary();
                        if (ok && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    child: Text(loc.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
