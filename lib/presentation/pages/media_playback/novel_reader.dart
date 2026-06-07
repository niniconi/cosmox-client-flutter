import 'package:flutter/material.dart';

class NovelReaderPage extends StatefulWidget {
  const NovelReaderPage({super.key});
  @override
  State<StatefulWidget> createState() => _NovelReaderPageState();
}

class _NovelReaderPageState extends State<NovelReaderPage> {
  String data = "null";

  Future<void> _fetchNovelData() async {}

  @override
  void initState() {
    super.initState();
    _fetchNovelData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Novel'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Text(data, style: const TextStyle(fontSize: 32)),
      ),
    );
  }
}
