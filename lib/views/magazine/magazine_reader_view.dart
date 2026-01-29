import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_flipbook/flutter_pdf_flipbook.dart';

import 'package:franchisemarketturkiye/viewmodels/magazine_reader_view_model.dart';
import 'package:franchisemarketturkiye/views/widgets/filling_logo_loader.dart';

class MagazineReaderView extends StatefulWidget {
  final String pdfUrl;
  final String? coverUrl;
  final int? magazineId;
  final String title;

  const MagazineReaderView({
    super.key,
    required this.pdfUrl,
    this.coverUrl,
    this.magazineId,
    required this.title,
  });

  @override
  State<MagazineReaderView> createState() => _MagazineReaderViewState();
}

class _MagazineReaderViewState extends State<MagazineReaderView> {
  late final MagazineReaderViewModel _viewModel;

  bool _isPdfRendered = false;

  @override
  void initState() {
    super.initState();
    _viewModel = MagazineReaderViewModel();

    // Tam ekran için sistem barlarını gizle
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Kullanıcının "dikeyde tek sayfa" isteği için sadece dikey modda tutuyoruz
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.preloadAndShow(widget.pdfUrl);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final bool showFlipbook = _viewModel.showPdf && _isPdfRendered;

          return Stack(
            children: [
              // 1. Kapak Görseli (Hero Animasyonlu - PDF yüklenene kadar gösterilir)
              if (!showFlipbook)
                Positioned.fill(
                  child: Hero(
                    tag: widget.magazineId != null
                        ? 'magazine_${widget.magazineId}'
                        : 'pdf_${widget.pdfUrl}',
                    child: widget.coverUrl != null
                        ? Image.network(widget.coverUrl!, fit: BoxFit.contain)
                        : const Center(
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                  ),
                ),

              // 2. PDF Görüntüleyici (Flipbook Animasyonlu)
              if (_viewModel.showPdf)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _isPdfRendered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: PdfBookViewer(
                      pdfUrl: widget.pdfUrl,
                      style: const PdfBookViewerStyle(
                        loadingIndicatorColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                      ),
                      onPageChanged: (current, total) {
                        if (!_isPdfRendered && current >= 0) {
                          setState(() {
                            _isPdfRendered = true;
                          });
                        }
                      },
                    ),
                  ),
                ),

              // 3. Özel Dolma Efektli Logo (Üstte)
              if (_viewModel.isLoading)
                AnimatedOpacity(
                  opacity: _viewModel.isLoading ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FillingLogoLoader(
                            size: 150,
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
            ],
          );
        },
      ),
    );
  }
}
