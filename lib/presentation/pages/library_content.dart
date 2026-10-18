import 'package:flutter/material.dart';
import 'package:cosmox_client_flutter/presentation/widgets/under_construction.dart';

class LibraryContentPage extends StatefulWidget {
  const LibraryContentPage({super.key, required this.lid});
  final int lid;

  @override
  State<LibraryContentPage> createState() => _LibraryContentPageState();
}

class _LibraryContentPageState extends State<LibraryContentPage> {
  @override
  Widget build(BuildContext context) {
    return const UnderConstructionWidget();
  }
}
