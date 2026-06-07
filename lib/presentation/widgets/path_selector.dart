import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/presentation/widgets/form.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/core/common.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class PathSelectorComponent extends StatefulWidget {
  final Function(String path) then;
  const PathSelectorComponent({super.key, required this.then});

  @override
  State<PathSelectorComponent> createState() => _PathSelectorComponentState();
}

class _PathSelectorComponentState extends State<PathSelectorComponent> {
  final Logger _logger = Logger('PathSelectorComponent');
  final _formKey = GlobalKey<FormState>();

  String parentPath = "/";
  String currentPath = "/";
  List<String> dirs = [];

  Future<void> _updatePaths() async {
    try {
      final entries = await SdkProxy.instance.pathSubPath(
        path: currentPath,
        showHide: false,
      );
      setState(() {
        dirs.clear();
        for (var e in entries) {
          if (currentPath.endsWith('/')) {
            dirs.add(currentPath + e);
          } else {
            dirs.add('$currentPath/$e');
          }
        }
      });
    } on SdkError catch (e) {
      _logger.warning('Path list failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
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
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: InputFormField(
                  labelText: "path",
                  controller: TextEditingController(text: currentPath),
                  validator: (val) => Validate.path(val),
                  onChanged: null,
                ),
              ),
              ListTile(
                title: currentPath == '/' ? const Text(".") : const Text("../"),
                onTap: () {
                  if (currentPath != '/') {
                    currentPath = currentPath.substring(
                      0,
                      currentPath.lastIndexOf('/'),
                    );
                    if (currentPath == '') {
                      currentPath = '/';
                    }
                    _updatePaths();
                  }
                },
              ),
              ...dirs.map(
                (element) => ListTile(
                  title: Text(element),
                  onTap: () {
                    currentPath = element;
                    _updatePaths();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.then(currentPath);
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
