import 'dart:convert';

import 'package:cosmox_client/core/sdk_proxy.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter/material.dart';
import 'package:cosmox_client/presentation/widgets/under_construction.dart';
import 'package:logging/logging.dart';

class MetadataEditorPage extends StatefulWidget {
  const MetadataEditorPage({super.key});

  @override
  State<StatefulWidget> createState() => _MetadataEditorPageState();
}

class _MetadataEditorPageState extends State<MetadataEditorPage> {
  final Logger _logger = Logger('MetadataEditorPage');
  Map<String, dynamic>? data;
  void _fetchMetadata() async {
    try {
      final jsonStr = await SdkProxy.instance.metadataQuery(
        rootNode: BigInt.from(8),
        depth: BigInt.from(3),
      );
      final decoded = jsonDecode(jsonStr);
      setState(() {
        data = decoded as Map<String, dynamic>?;
      });
    } on SdkError catch (e) {
      _logger.warning('Metadata query failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMetadata();
  }

  final myTreeController = TreeSliverController();

  Widget _buildMetadataTree(Map<String, dynamic> metadata) {
    // List<Widget> widgets = [
    //   Text(metadata["name"], overflow: TextOverflow.ellipsis, maxLines: 1),
    // ];
    // final childs = (metadata["sub_metadatas"] as List<dynamic>).map((x) {
    //   return _buildMetadataTree(metadata);
    // }).toList();
    // widgets.addAll(childs);
    return TreeSliver<String>(
      tree: [TreeSliverNode("hello")],
      controller: myTreeController,
      treeRowExtentBuilder: (node, details) => 40.0, // Extent of each row
      treeNodeBuilder: (context, node, details) {
        return Padding(
          padding: EdgeInsets.only(left: 20.0), // Indent based on depth
          child: Text('Node: ${node.content}'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return data == null
        ? const UnderConstructionWidget()
        : _buildMetadataTree(data!);
  }
}
