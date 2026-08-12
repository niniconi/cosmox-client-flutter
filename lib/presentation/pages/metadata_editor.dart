import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/presentation/pages/error.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class MetadataEditorPage extends StatefulWidget {
  const MetadataEditorPage({super.key});

  @override
  State<MetadataEditorPage> createState() => _MetadataEditorPageState();
}

class _MetadataEditorPageState extends State<MetadataEditorPage> {
  final Logger _logger = Logger('MetadataEditorPage');
  final _rootNodeController = TextEditingController();
  final _depthController = TextEditingController(text: '3');

  bool _loading = false;
  MetadataNode? _root;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _rootNodeController.dispose();
    _depthController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rootNodeText = _rootNodeController.text.trim();
      final rootNode = rootNodeText.isEmpty ? null : int.tryParse(rootNodeText);
      final depth = int.tryParse(_depthController.text) ?? 3;

      _root = await SdkProxy.instance.metadataQuery(
        rootNode: rootNode == null ? null : BigInt.from(rootNode),
        depth: BigInt.from(depth),
      );
    } catch (e) {
      _logger.severe('Metadata query failed', e);
      _error = '$e';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildQueryBar(),
        const Divider(height: 1),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildQueryBar() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      color: cs.surface,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: TextField(
              controller: _rootNodeController,
              decoration: const InputDecoration(
                labelText: 'Root node (empty = root)',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _depthController,
              decoration: const InputDecoration(
                labelText: 'Depth',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _fetch,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search, size: 18),
            label: const Text('Query'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ErrorBlock(
        title: 'Failed to load metadata',
        message: _error!,
        onRetry: _fetch,
      );
    }

    if (_root == null) {
      return Center(
        child: Text(
          'No metadata found',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [_buildNode(_root!, 0)],
    );
  }

  Widget _buildNode(MetadataNode node, int depth) {
    final hasChildren = node.subMetadatas.isNotEmpty;
    final children = node.subMetadatas
        .map((child) => _buildNode(child, depth + 1))
        .toList();

    return Padding(
      padding: EdgeInsets.only(left: (depth * 20.0).clamp(0, 100)),
      child: _buildNodeTile(node, depth, hasChildren, children),
    );
  }

  Widget _buildNodeTile(
    MetadataNode node,
    int depth,
    bool hasChildren,
    List<Widget> children,
  ) {
    final cs = Theme.of(context).colorScheme;

    final header = _buildNodeHeader(node, hasChildren, cs);

    if (!hasChildren) {
      return header;
    }

    return ExpansionTile(
      initiallyExpanded: depth == 0,
      dense: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      childrenPadding: EdgeInsets.zero,
      title: header,
      children: [if (depth == 0) _buildDetails(node, cs), ...children],
    );
  }

  Widget _buildNodeHeader(MetadataNode node, bool hasChildren, ColorScheme cs) {
    final isDir = _isDirectoryType(node.metadataType);
    final header = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          Icon(
            isDir ? Icons.folder : Icons.insert_drive_file,
            size: 18,
            color: isDir ? cs.primary : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name.isEmpty ? '(unnamed)' : node.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (node.description.isNotEmpty)
                  Text(
                    node.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              node.metadataType.name,
              style: TextStyle(fontSize: 11, color: cs.onPrimaryContainer),
            ),
          ),
          if (hasChildren)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                '${node.subMetadatas.length}',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
            tooltip: 'View details',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            onPressed: () => _showNodeDetail(node),
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        if (node.extend.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 2,
              children: node.extend.entries
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${e.key}=${e.value}',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDetails(MetadataNode node, ColorScheme cs) {
    final details = <String, String>{
      'ID': 'lid=${node.lid}, rid=${node.rid}',
      'File': '${node.fileCnt} files, ${node.fileSize} bytes',
      'Origin': node.originName,
    };

    return Padding(
      padding: const EdgeInsets.only(left: 56, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: details.entries
            .where((e) => e.value.isNotEmpty)
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${e.key}: ${e.value}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  bool _isDirectoryType(MetadataType type) {
    return type == MetadataType.directory;
  }

  void _showNodeDetail(MetadataNode node) {
    showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 48,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    node.name.isEmpty ? '(unnamed)' : node.name,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (node.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      node.description,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _detailEntry('Type', node.metadataType.name, cs),
                  _detailEntry('LID', '${node.lid}', cs),
                  _detailEntry('RID', '${node.rid}', cs),
                  _detailEntry('Origin Name', node.originName, cs),
                  _detailEntry('Origin', node.origin, cs),
                  _detailEntry('File Count', '${node.fileCnt}', cs),
                  _detailEntry('File Size', '${node.fileSize} bytes', cs),
                  _detailEntry('Flags', '${node.flags}', cs),
                  _detailEntry('URL', node.url, cs),
                  if (node.aliasName.isNotEmpty)
                    _detailEntry('Alias', node.aliasName.join(', '), cs),
                  if (node.dataFileMapId != null)
                    _detailEntry(
                      'Data File Map ID',
                      '${node.dataFileMapId}',
                      cs,
                    ),
                  if (node.coverFileMapId != null)
                    _detailEntry(
                      'Cover File Map ID',
                      '${node.coverFileMapId}',
                      cs,
                    ),
                  if (node.checksum.isNotEmpty)
                    _detailEntry('Checksum', node.checksum, cs),
                  ...node.extend.entries.map(
                    (e) => _detailEntry(e.key, e.value, cs),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailEntry(String label, String value, ColorScheme cs) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
