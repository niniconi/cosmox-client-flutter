import 'package:flutter/material.dart';
import 'package:cosmox_client/presentation/widgets/under_construction.dart';

class PluginManagerPage extends StatefulWidget {
  const PluginManagerPage({super.key});
  @override
  State<PluginManagerPage> createState() => _PluginManagerPageState();
}

class _PluginManagerPageState extends State<PluginManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.small(
              onPressed: () => showUnderConstructionSnackBar(context),
              child: const Icon(Icons.add),
            ),
          ),
        ),
        const Expanded(child: UnderConstructionWidget()),
      ],
    );
  }
}
