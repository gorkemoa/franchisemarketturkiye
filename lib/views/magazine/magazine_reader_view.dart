import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_flipbook/flutter_pdf_flipbook.dart';
import 'package:franchisemarketturkiye/views/widgets/filling_logo_loader.dart';

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
  bool _isLandscape = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Allow user to rotate phone physically
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });

    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PdfBookViewer(
              pdfUrl: widget.pdfUrl,
              style: const PdfBookViewerStyle(
                loadingIndicatorColor: Colors.transparent,
                backgroundColor: Colors.transparent,
              ),
              onPageChanged: (int currentPage, int totalPages) {
                if (_isLoading) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onError: (error) {
                if (_isLoading) {
                  setState(() {
                    _isLoading = false;
                  });
                  // Optionally show error snackbar
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $error')));
                }
              },
            ),
          ),
          if (_isLoading) const Center(child: FillingLogoLoader(size: 150)),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: _toggleOrientation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isLandscape
                      ? Icons.screen_lock_portrait
                      : Icons.screen_rotation,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
