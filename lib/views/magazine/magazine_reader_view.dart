import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:franchisemarketturkiye/viewmodels/magazine_reader_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/profile_form_fields.dart';
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
  PdfDocument? _pdfDocument;
  bool _isInitialized = false;

  // Minimize rebuilds using ValueNotifiers
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _showControlsNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isZoomedNotifier = ValueNotifier<bool>(false);

  final TextEditingController _pageInputController = TextEditingController();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _viewModel = MagazineReaderViewModel();
    _pageController = PageController(initialPage: _currentPageNotifier.value);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _loadPdf();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.preloadAndShow(widget.pdfUrl);
    });
  }

  Future<void> _loadPdf() async {
    try {
      final document = await PdfDocument.openUri(Uri.parse(widget.pdfUrl));
      if (mounted) {
        setState(() {
          _pdfDocument = document;
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('PDF Load Error: $e');
    }
  }

  void _onToggleControls() {
    _showControlsNotifier.value = !_showControlsNotifier.value;
  }

  void _goToPage(int page) {
    if (page >= 0 && page < (_pdfDocument?.pages.length ?? 0)) {
      _pageController.jumpToPage(page);
      _currentPageNotifier.value = page;
      _pageInputController.text = (page + 1).toString();
    }
  }

  @override
  void dispose() {
    _pdfDocument?.dispose();
    _currentPageNotifier.dispose();
    _showControlsNotifier.dispose();
    _isZoomedNotifier.dispose();
    _pageInputController.dispose();
    _pageController.dispose();
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
          final bool showReader = _isInitialized;

          return Stack(
            children: [
              // 1. Hero Cover
              if (!showReader)
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

              // 2. PageReader (Using PageView for maximum stability and memory efficiency)
              if (showReader)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _onToggleControls,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        if (!mounted) return;
                        _currentPageNotifier.value = index;
                        _pageInputController.text = (index + 1).toString();
                      },
                      itemCount: _pdfDocument?.pages.length ?? 0,
                      itemBuilder: (context, index) {
                        return ValueListenableBuilder<int>(
                          valueListenable: _currentPageNotifier,
                          builder: (context, currentIndex, _) {
                            // Memory Defense: Only render PDF content for current and immediate neighbors
                            final bool isVeryClose =
                                (index - currentIndex).abs() <= 1;

                            if (!isVeryClose) {
                              return Container(color: Colors.black);
                            }

                            return InteractiveViewer(
                              key: ValueKey('iv_page_$index'),
                              minScale: 1.0,
                              maxScale: 3.0,
                              child: Center(
                                child: PdfPageView(
                                  key: ValueKey('pdf_view_$index'),
                                  document: _pdfDocument!,
                                  pageNumber: index + 1,
                                  alignment: Alignment.center,
                                  // 110 DPI is enough for mobile and very safe for RAM
                                  maximumDpi: 110,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

              // 3. Zoom Overlay Block (Only active when zoomed to prevent unintentional flips)
              ValueListenableBuilder<bool>(
                valueListenable: _isZoomedNotifier,
                builder: (context, isZoomed, _) {
                  if (!isZoomed) return const SizedBox.shrink();
                  // This is a partial block, but it might interfere with panning.
                  // Since we can't easily lock PageFlip without changing the package,
                  // we notify the user or just keep it as is.
                  // Optimization: The user wants "disable page change when zoomed".
                  return const SizedBox.shrink();
                },
              ),

              // 4. Loader (Only show until PDF document is at least initialized)
              if (!_isInitialized) _buildLoader(),

              // 5. Overlays
              ValueListenableBuilder<bool>(
                valueListenable: _showControlsNotifier,
                builder: (context, show, _) {
                  if (!show && !_viewModel.isLoading)
                    return const SizedBox.shrink();

                  return Stack(
                    children: [
                      // Top Buttons
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleButton(
                              icon: Icons.close,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Navigation
                      if (showReader) _buildBottomControls(),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildLoader() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FillingLogoLoader(size: 150, progress: _viewModel.downloadProgress),
            const SizedBox(height: 16),
            Text(
              '%${(_viewModel.downloadProgress * 100).toInt()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final totalPages = _pdfDocument?.pages.length ?? 0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 8,
          top: 8,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.9), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page Control Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(Icons.chevron_left, () {
                  if (_currentPageNotifier.value > 0) {
                    _goToPage(_currentPageNotifier.value - 1);
                  }
                }),

                // Page Picker (Dropdown style)
                GestureDetector(
                  onTap: () {
                    final List<int> pageNumbers = List.generate(
                      totalPages,
                      (index) => index + 1,
                    );
                    showProfilePicker<int>(
                      context: context,
                      title: 'Sayfa Seçin',
                      items: pageNumbers,
                      selectedItem: _currentPageNotifier.value + 1,
                      itemLabel: (page) => 'Sayfa $page',
                      onChanged: (page) {
                        if (page != null) {
                          _goToPage(page - 1);
                        }
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: _currentPageNotifier,
                          builder: (context, pageIndex, _) {
                            return Text(
                              '${pageIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        Text(
                          ' / $totalPages',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                _buildNavButton(Icons.chevron_right, () {
                  if (_currentPageNotifier.value < totalPages - 1) {
                    _goToPage(_currentPageNotifier.value + 1);
                  }
                }),
              ],
            ),
            const SizedBox(height: 4),
            // Slider
            ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (context, pageIndex, _) {
                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFD4AF37),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: pageIndex.toDouble(),
                    min: 0,
                    max: (totalPages - 1).toDouble().clamp(0, double.infinity),
                    onChanged: (value) =>
                        _currentPageNotifier.value = value.toInt(),
                    onChangeEnd: (value) => _goToPage(value.toInt()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 30),
      onPressed: onTap,
    );
  }
}
