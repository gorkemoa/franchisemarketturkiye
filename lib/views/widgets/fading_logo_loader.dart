import 'package:flutter/material.dart';

class FadingLogoLoader extends StatefulWidget {
  final double size;
  const FadingLogoLoader({super.key, this.size = 100.0});

  @override
  State<FadingLogoLoader> createState() => _FadingLogoLoaderState();
}

class _FadingLogoLoaderState extends State<FadingLogoLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Image.asset(
                'assets/FranchiseIcon.png',
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
