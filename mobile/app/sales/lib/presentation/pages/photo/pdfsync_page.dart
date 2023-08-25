import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Represents PdfSyncPage for Navigation
class PdfSyncPage extends StatefulWidget {
  const PdfSyncPage({super.key, required this.imageUrl});
  final String imageUrl;
  @override
  _PdfSyncPage createState() => _PdfSyncPage();
}

class _PdfSyncPage extends State<PdfSyncPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SfPdfViewer.network(
        widget.imageUrl,
        key: _pdfViewerKey,
      ),
    );
  }
}
