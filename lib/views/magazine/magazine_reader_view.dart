import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_flipbook/flutter_pdf_flipbook.dart';
import 'package:franchisemarketturkiye/viewmodels/magazine_reader_view_model.dart';
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
  late final MagazineReaderViewModel _viewModel;
  bool _isLandscape = false;
  bool _isPdfRendered = false;

  @override
  void initState() {
    super.initState();
    _viewModel = MagazineReaderViewModel();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.preloadAndShow(widget.pdfUrl);
    });
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
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          // Loader hem indirme bitene kadar hem de PDF ilk sayfasını çizene kadar gösterilir
          final bool isVisible = !_isPdfRendered || _viewModel.isLoading;

          return Stack(
            children: [
              // 1. PDF Görüntüleyici (En altta, her zaman aktif)
              Positioned.fill(
                child: PdfBookViewer(
                  pdfUrl: widget.pdfUrl,
                  style: const PdfBookViewerStyle(
                    loadingIndicatorColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                  ),
                  onPageChanged: (current, total) {
                    // PDF'in gerçekten ekrana geldiğini anladığımız an
                    if (!_isPdfRendered && current > 0) {
                      setState(() {
                        _isPdfRendered = true;
                      });
                    }
                  },
                ),
              ),

              // 2. Özel Dolma Efektli Logo (Üstte)
              if (isVisible)
                AnimatedOpacity(
                  opacity: isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FillingLogoLoader(
                            size: 150,
                            // İndirme progresini ViewModel'den alıyoruz
                            progress: _viewModel.downloadProgress,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '%${(_viewModel.downloadProgress * 100).toInt()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 3. Kontrol Butonları
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
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
          );
        },
      ),
    );
  }
}
