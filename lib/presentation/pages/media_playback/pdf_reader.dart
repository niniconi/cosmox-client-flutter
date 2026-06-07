import 'package:flutter/material.dart';
import 'package:cosmox_client/presentation/widgets/under_construction.dart';

class PDFReaderPage extends StatefulWidget {
  const PDFReaderPage({super.key, required this.pdfUrl});
  final String pdfUrl;
  @override
  State<PDFReaderPage> createState() => _PDFReaderPageState();
}

class _PDFReaderPageState extends State<PDFReaderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('PDF'),
        elevation: 0,
      ),
      body: const UnderConstructionWidget(),
    );
  }
}
