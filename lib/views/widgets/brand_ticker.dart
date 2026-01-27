import 'dart:async';
import 'package:flutter/material.dart';

class BrandTicker extends StatefulWidget {
  const BrandTicker({super.key});

  @override
  State<BrandTicker> createState() => _BrandTickerState();
}

class _BrandTickerState extends State<BrandTicker> {
  late final ScrollController _scrollController;
  late Timer _timer;
  final double _scrollSpeed = 1.0; // Pixels per tick
  final Duration _tickDuration = const Duration(milliseconds: 30);

  // Dummy list of brands - matches the image provided
  final List<String> _brands = [
    'OTORAPOR',
    'YAPRAK DÖNERCİSİ',
    'BEREKET DÖNER',
    'KÖFTECİ YUSUF',
    'KOMAGENE',
    'DOMİNOS',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Start auto-scrolling after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(_tickDuration, (timer) {
      if (!_scrollController.hasClients) return;

      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        // Reset to start for infinite loop effect
        // For smoother infinite loop, we would need to duplicate items,
        // but for now creating a "reset" effect is acceptable or we reverse.
        // Let's just scroll back to 0 smoothly or jump.
        _scrollController.jumpTo(0);
      } else {
        _scrollController.animateTo(
          currentScroll + _scrollSpeed,
          duration: _tickDuration,
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  '29. SAYIMIZDA YER ALAN MARKALAR',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Marquee Content
          SizedBox(
            height: 80,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              // Make it effectively infinite for the user by having a large count
              // or just relying on the jumpTo(0) loop logic with enough items.
              // To make jumpTo(0) seamless, we'd need many items.
              itemCount: _brands.length * 100,
              itemBuilder: (context, index) {
                final brandName = _brands[index % _brands.length];
                return _buildBrandItem(brandName);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandItem(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      alignment: Alignment.center,
      child: Text(
        name,
        style: TextStyle(
          color: Colors.grey[500],
          fontWeight: FontWeight.bold,
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
