import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';

class AddPluginComponent extends StatefulWidget {
  const AddPluginComponent({super.key});

  @override
  State<AddPluginComponent> createState() => _AddPluginComponentState();
}

class _AddPluginComponentState extends State<AddPluginComponent> {
  final _urlController = TextEditingController();
  bool _installing = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _install() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a plugin URL.');
      return;
    }

    setState(() {
      _installing = true;
      _error = null;
    });

    try {
      await SdkProxy.instance.pluginInstall(url: url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plugin installed successfully')),
        );
        context.pop(true);
      }
    } catch (error) {
      setState(() {
        _installing = false;
        _error = 'Failed to install plugin: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Install Plugin', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Plugin URL',
              hintText: 'https://example.com/plugin.tar.gz',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            enabled: !_installing,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _installing ? null : () => context.pop(false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _installing ? null : _install,
                child: _installing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Install'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
