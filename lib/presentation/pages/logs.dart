import 'dart:io';

import 'package:cosmox_client/core/global_keys.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/core/sdk_proxy.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final Logger _logger = Logger('LogsPage');
  String? _logs;

  Future<void> _fetchLogs() async {
    try {
      final content = await SdkProxy.instance.systemLog();
      _logger.fine('Logs loaded: ${content.length} chars');
      setState(() {
        _logs = content;
      });
    } catch (error) {
      _logger.severe('Failed to fetch logs', error);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Failed to load logs: $error")),
      );
    }
  }

  void _saveLogs() async {
    if (_logs == null) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('${path.toString()}/system.log');
    file.writeAsString(_logs!);

    if (!mounted) return;

    SnackBar message = SnackBar(
      behavior: SnackBarBehavior.floating,
      width: MediaQuery.of(context).size.width * 0.8,
      content: Text('${path.toString()}/system.log'),
    );
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(message);
  }

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveLogs,
        label: Text(AppLocalizations.of(context)!.download),
        icon: const Icon(Icons.download),
      ),
      body: RefreshIndicator(
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) => Text(_logs ?? "(null)"),
        ),
        onRefresh: () async {
          await _fetchLogs();
        },
      ),
    );
  }
}
