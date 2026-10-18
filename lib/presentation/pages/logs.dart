import 'dart:io';
import 'dart:math';

import 'package:cosmox_client_flutter/core/global_keys.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:cosmox_client_flutter/presentation/pages/error.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final Logger _logger = Logger('LogsPage');

  late Future<List<LogFileInfo>> _logFilesFuture;

  List<LogFileInfo> _logFiles = [];
  LogFileInfo? _selectedFile;
  LogLevel? _selectedLevel;
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();

  SystemLogResponse? _logs;
  String? _error;

  @override
  void initState() {
    super.initState();
    _logFilesFuture = _fetchLogFiles();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<List<LogFileInfo>> _fetchLogFiles() async {
    try {
      final files = await SdkProxy.instance.systemLogFiles();
      _logger.fine('Log files loaded: ${files.length}');
      if (!mounted) return files;
      setState(() {
        _logFiles = files;
        if (files.isNotEmpty && _selectedFile == null) {
          _selectedFile = files.first;
        }
      });
      if (_selectedFile != null) {
        _fetchLogs();
      }
      return files;
    } catch (error) {
      _logger.severe('Failed to fetch log files', error);
      rethrow;
    }
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _error = null;
      _logs = null;
    });
    try {
      final params = SystemLogRequest(
        file: _selectedFile?.name,
        level: _selectedLevel,
        keyword: _keywordController.text.isEmpty
            ? null
            : _keywordController.text,
        limit: _limitController.text.isEmpty
            ? null
            : BigInt.tryParse(_limitController.text),
      );
      final response = await SdkProxy.instance.systemLog(params: params);
      _logger.fine(
        'Logs loaded: matched ${response.total} entries, show ${min(response.total.toInt(), params.limit == null ? double.infinity : params.limit!.toInt())}',
      );
      if (!mounted) return;
      setState(() {
        _logs = response;
      });
    } catch (error) {
      _logger.severe('Failed to fetch logs', error);
      if (!mounted) return;
      setState(() {
        _error = '$error';
      });
    }
  }

  void _saveLogs() {
    if (_logs == null) return;
    final content = _logs!.logs.join('\n');
    getApplicationDocumentsDirectory().then((directory) {
      final savePath =
      '${directory.path}/cosmox-system-${_logs!.file}.log';
      final file = File(savePath);
      file.writeAsString(content);
      if (!mounted) return;
      scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.of(context).size.width * 0.8,
          content: Text('Saved into $savePath'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logs != null ? _saveLogs : null,
        label: Text(AppLocalizations.of(context)!.download),
        icon: const Icon(Icons.download),
      ),
      body: FutureBuilder<List<LogFileInfo>>(
        future: _logFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeleton();
          }
          if (snapshot.hasError) {
            return ErrorBlock(
              message: '${snapshot.error}',
              onRetry: () {
                setState(() {
                  _logFilesFuture = _fetchLogFiles();
                });
              },
            );
          }
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFilterBar(isLoading: true),
          const SizedBox(height: 16),
          ...List.generate(
            8,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('14:32:01 INFO  Application started' * 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _logFilesFuture = _fetchLogFiles();
        });
        await _logFilesFuture;
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildFilterBar(isLoading: false),
          const SizedBox(height: 16),
          if (_logs != null) ...[
            _buildLogHeader(),
            const SizedBox(height: 8),
            ..._logs!.logs.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  line,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
          if (_logs == null && _error == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text('No logs loaded')),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ErrorBlock(message: _error!, onRetry: _fetchLogs),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar({required bool isLoading}) {
    return Skeletonizer(
      enabled: isLoading,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 290,
            child: DropdownButtonFormField<LogFileInfo>(
              initialValue: _selectedFile,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'File',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _logFiles
                  .map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(
                        '${f.name}  (${f.date})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedFile = value;
                      });
                      _fetchLogs();
                    },
            ),
          ),
          SizedBox(
            width: 130,
            child: DropdownButtonFormField<LogLevel>(
              initialValue: _selectedLevel,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Level',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: LogLevel.trace, child: Text('Trace')),
                DropdownMenuItem(value: LogLevel.debug, child: Text('Debug')),
                DropdownMenuItem(value: LogLevel.info, child: Text('Info')),
                DropdownMenuItem(value: LogLevel.warn, child: Text('Warn')),
                DropdownMenuItem(value: LogLevel.error, child: Text('Error')),
              ],
              onChanged: isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedLevel = value;
                      });
                      _fetchLogs();
                    },
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _limitController,
              enabled: !isLoading,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Limit',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _fetchLogs(),
            ),
          ),
          SizedBox(
            width: 160,
            child: TextField(
              controller: _keywordController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Keyword',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _fetchLogs(),
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : _fetchLogs,
            icon: const Icon(Icons.search),
            tooltip: 'Apply filters',
          ),
        ],
      ),
    );
  }

  Widget _buildLogHeader() {
    final cs = Theme.of(context).colorScheme;
    final matchedText = _limitController.text.isEmpty
        ? 'matched ${_logs!.total} entries;'
        : 'matched ${int.tryParse(_limitController.text)}/${_logs!.total} entries';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 16,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _logs!.file,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            matchedText,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
