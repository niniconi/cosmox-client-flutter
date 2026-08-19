import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/presentation/widgets/form.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/core/common.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class PathSelectorComponent extends StatefulWidget {
  final ValueChanged<String> then;
  const PathSelectorComponent({super.key, required this.then});

  @override
  State<PathSelectorComponent> createState() => _PathSelectorComponentState();
}

class _PathSelectorComponentState extends State<PathSelectorComponent> {
  final Logger _logger = Logger('PathSelectorComponent');
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _pathController;

  String _currentPath = '/';
  List<String> _dirs = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: _currentPath);
    _updatePaths();
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  String _parentPath(String path) {
    if (path == '/' || path.isEmpty) return '/';
    final trimmed = path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    final idx = trimmed.lastIndexOf('/');
    if (idx <= 0) return '/';
    return trimmed.substring(0, idx);
  }

  Future<void> _updatePaths() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entries = await SdkProxy.instance.pathSubPath(
        path: _currentPath,
        showHide: false,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        final base = _currentPath.endsWith('/')
            ? _currentPath
            : '$_currentPath/';
        _dirs
          ..clear()
          ..addAll(entries.map((e) => '$base$e').toList()..sort());
      });
    } on SdkError catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to list path';
      });
      _logger.warning('Path list failed: $error');
    }
  }

  void _navigateTo(String path) {
    _currentPath = path;
    _pathController.text = path;
    _updatePaths();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: InputFormField(
                  labelText: 'path',
                  controller: _pathController,
                  validator: (val) => Validate.path(val),
                  onFieldSubmitted: (_) {
                    if (_formKey.currentState!.validate()) {
                      _navigateTo(_pathController.text);
                    }
                  },
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _navigateTo(_pathController.text);
                      }
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
              ListTile(
                title: Text(_currentPath == '/' ? 'Root' : '../'),
                onTap: () {
                  if (_currentPath != '/') {
                    _navigateTo(_parentPath(_currentPath));
                  }
                },
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                )
              else
                ..._dirs.map(
                  (element) => ListTile(
                    title: Text(element),
                    onTap: () => _navigateTo(element),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.then(_pathController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
