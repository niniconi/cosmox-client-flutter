import 'package:cosmox_client_flutter/core/global_keys.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/presentation/widgets/add_plugin.dart';
import 'package:cosmox_client_flutter/presentation/widgets/dialog.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PluginManagerPage extends StatefulWidget {
  const PluginManagerPage({super.key});

  @override
  State<PluginManagerPage> createState() => _PluginManagerPageState();
}

class _PluginManagerPageState extends State<PluginManagerPage> {
  final Logger _logger = Logger('PluginManagerPage');
  bool _loaded = false;
  List<PluginQueryItem> _plugins = [];

  @override
  void initState() {
    super.initState();
    _fetchPlugins();
  }

  Future<void> _fetchPlugins() async {
    try {
      final result = await SdkProxy.instance.pluginQuery();
      setState(() {
        _plugins = result;
        _loaded = true;
      });
    } catch (error) {
      _logger.severe('Failed to fetch plugins', error);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to fetch plugins: $error')),
      );
      setState(() => _loaded = true);
    }
  }

  Future<void> _togglePlugin(PluginQueryItem plugin) async {
    try {
      if (plugin.enabled) {
        await SdkProxy.instance.pluginDisable(name: plugin.name);
      } else {
        await SdkProxy.instance.pluginEnable(name: plugin.name);
      }
      _fetchPlugins();
    } catch (error) {
      _logger.severe('Failed to toggle plugin', error);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to toggle plugin: $error')),
      );
    }
  }

  Future<void> _uninstallPlugin(int index) async {
    final plugin = _plugins[index];
    try {
      await SdkProxy.instance.pluginUninstall(name: plugin.name);
      setState(() => _plugins.removeAt(index));
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Uninstalled plugin ${plugin.name}')),
      );
    } catch (error) {
      _logger.severe('Failed to uninstall plugin', error);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to uninstall plugin: $error')),
      );
    }
  }

  static IconData _pluginIcon(String pluginType) {
    switch (pluginType) {
      case 'builtin':
        return Icons.build_circle;
      case 'external':
        return Icons.extension;
      case 'invalid':
        return Icons.error;
      default:
        return Icons.extension;
    }
  }

  static Color _pluginColor(String pluginType) {
    switch (pluginType) {
      case 'builtin':
        return Colors.blue;
      case 'external':
        return Colors.green;
      case 'invalid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _pluginCard(int index) {
    final plugin = _plugins[index];
    final isInvalid = plugin.pluginType == 'invalid';

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _pluginIcon(plugin.pluginType),
                  color: _pluginColor(plugin.pluginType),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plugin.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (plugin.version.isNotEmpty)
                        Text(
                          'v${plugin.version}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isInvalid)
                  Switch(
                    value: plugin.enabled,
                    onChanged: (_) => _togglePlugin(plugin),
                  )
                else
                  const Icon(Icons.warning_amber, color: Colors.orange),
                PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      if (!isInvalid)
                        PopupMenuItem(
                          child: Text(
                            plugin.enabled
                                ? AppLocalizations.of(context)!.disable
                                : AppLocalizations.of(context)!.enable,
                          ),
                          onTap: () => _togglePlugin(plugin),
                        ),
                      PopupMenuItem(
                        child: Text(AppLocalizations.of(context)!.uninstall),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => DialogProvider.alert(
                              context,
                              title: AppLocalizations.of(
                                context,
                              )!.confirmUninstallPlugin,
                              content: [
                                'Are you sure you want to uninstall "${plugin.name}"?',
                              ],
                              confirmAction: () {
                                _uninstallPlugin(index);
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
            if (plugin.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  plugin.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
            if (plugin.author.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'by ${plugin.author}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            if (plugin.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  plugin.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget main = const Center(child: CircularProgressIndicator());

    if (_loaded) {
      if (_plugins.isEmpty) {
        main = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.noPlugins,
                style: TextStyle(
                  fontSize: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Icon(
                Icons.extension_off,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      } else {
        main = SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            width: ResponsiveBreakpoints.of(context).screenWidth,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Wrap(
              children: List.generate(_plugins.length, (index) {
                return SizedBox(width: 380, child: _pluginCard(index));
              }),
            ),
          ),
        );
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.of(context)!.addPlugin,
        onPressed: () async {
          final added = await showDialog<bool>(
            context: context,
            builder: (context) => const Dialog(child: AddPluginComponent()),
          );
          if (added == true) {
            _fetchPlugins();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(onRefresh: _fetchPlugins, child: main),
    );
  }
}
