import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ContainerInfoComponent extends StatefulWidget {
  const ContainerInfoComponent({super.key, required this.data});
  final Map data;
  @override
  State<ContainerInfoComponent> createState() => _ContainerInfoComponentState();
}

class _ContainerInfoComponentState extends State<ContainerInfoComponent> {
  final Logger _logger = Logger('ContainerInfoComponent');

  Widget _buildInfoTree(int layer, Map data) {
    List<Widget> subElement = [];
    _logger.fine(data);

    data.map((key, value) {
      if (value is String) {
        subElement.add(Text("${key.toString()}  ${value.toString()}"));
      } else if (value is List) {
        for (var element in value) {
          _logger.fine(element);
        }
      } else if (value is Map) {
        subElement.add(_buildInfoTree(layer + 1, value));
      }
      return MapEntry(key, value);
    });

    if (layer % 2 == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subElement,
      );
    } else {
      return Row(children: subElement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(widget.data["name"]), _buildInfoTree(0, widget.data)],
        ),
      ),
    );
  }
}
