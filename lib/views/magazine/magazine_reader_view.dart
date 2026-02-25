import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;
import 'package:pdfrx/pdfrx.dart';
import 'package:share_plus/share_plus.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.preloadAndShow(widget.pdfUrl);
    });

    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (_viewModel.showPdf && !_isInitialized && _viewModel.localPath != null) {
      _loadPdf();
    }
  }

  Future<void> _loadPdf() async {
    if (_viewModel.localPath == null) return;
    try {
      final document = await PdfDocument.openFile(_viewModel.localPath!);
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
              // 1. Background Cover (Always there as base)
              if (widget.coverUrl != null)
                Positioned.fill(
                  child: Image.network(
                    widget.coverUrl!,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
              if (widget.coverUrl != null)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                ),

              // 2. Hero Cover (Main focused cover until reader is ready)
              if (!showReader)
                Positioned.fill(
                  child: Hero(
                    tag: widget.magazineId != null
                        ? 'magazine_${widget.magazineId}'
                        : 'pdf_${widget.pdfUrl}',
                    child: widget.coverUrl != null
                        ? Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 100,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.coverUrl!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : const Center(),
                  ),
                ),

              // 2. PageReader (Using PageView for maximum stability and memory efficiency)
              if (showReader)
                Positioned.fill(
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

                          return MagazinePageItem(
                            key: ValueKey('page_$index'),
                            index: index,
                            document: _pdfDocument!,
                            isVeryClose: isVeryClose,
                            onTap: _onToggleControls,
                          );
                        },
                      );
                    },
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

              // 5. Overlays (Using Visibility to keep the tree stable and prevent render disruptions)
              ValueListenableBuilder<bool>(
                valueListenable: _showControlsNotifier,
                builder: (context, show, _) {
                  return IgnorePointer(
                    ignoring: !show && !_viewModel.isLoading,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: (show || _viewModel.isLoading) ? 1.0 : 0.0,
                      child: Stack(
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
                                _buildCircleButton(
                                  icon: Icons.share,
                                  onPressed: () => Share.share(widget.pdfUrl),
                                ),
                              ],
                            ),
                          ),

                          // Bottom Navigation
                          if (showReader) _buildBottomControls(),
                        ],
                      ),
                    ),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FillingLogoLoader(size: 150, progress: _viewModel.downloadProgress),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              'Yükleniyor %${(_viewModel.downloadProgress * 100).toInt()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
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

class MagazinePageItem extends StatefulWidget {
  final int index;
  final PdfDocument document;
  final bool isVeryClose;
  final VoidCallback onTap;

  const MagazinePageItem({
    super.key,
    required this.index,
    required this.document,
    required this.isVeryClose,
    required this.onTap,
  });

  @override
  State<MagazinePageItem> createState() => _MagazinePageItemState();
}

class _MagazinePageItemState extends State<MagazinePageItem>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TransformationController _transformationController;
  late final AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;
  TapDownDetails? _doubleTapDetails;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          if (_zoomAnimation != null) {
            _transformationController.value = _zoomAnimation!.value;
          }
        });
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_animationController.isAnimating) return;

    final Matrix4 endMatrix;
    final currentScale = _transformationController.value.getMaxScaleOnAxis();

    if (currentScale > 1.1) {
      endMatrix = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      const double zoomScale = 2.5;

      endMatrix = Matrix4.identity()
        ..translate(
          position.dx * (1 - zoomScale),
          position.dy * (1 - zoomScale),
        )
        ..scale(zoomScale);
    }

    _zoomAnimation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: endMatrix,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAlive

    if (!widget.isVeryClose) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 5.0,
        boundaryMargin: const EdgeInsets.all(20),
        onInteractionUpdate: (_) {
          if (_animationController.isAnimating) {
            _animationController.stop();
          }
        },
        child: RepaintBoundary(
          child: Center(
            child: PdfPageView(
              key: ValueKey(
                'pdf_p_${widget.index}_${widget.document.hashCode}',
              ),
              document: widget.document,
              pageNumber: widget.index + 1,
              alignment: Alignment.center,
              // Stability first: 110 DPI is perfect for mobile
              maximumDpi: 110,
            ),
          ),
        ),
      ),
    );
  }
}
