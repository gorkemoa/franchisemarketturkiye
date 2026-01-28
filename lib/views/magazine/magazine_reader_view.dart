import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class MagazineReaderView extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const MagazineReaderView({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<MagazineReaderView> createState() => _MagazineReaderViewState();
}

class _MagazineReaderViewState extends State<MagazineReaderView> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GlobalScaffold(
      showBackButton: true,
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'BioSans',
        ),
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        key: _pdfViewerKey,
        canShowScrollHead: false,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Dergi yüklenirken hata oluştu: ${details.description}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
