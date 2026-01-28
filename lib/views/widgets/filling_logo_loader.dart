import 'package:flutter/material.dart';

class FillingLogoLoader extends StatefulWidget {
  final double size;
  const FillingLogoLoader({super.key, this.size = 100.0});

  @override
  State<FillingLogoLoader> createState() => _FillingLogoLoaderState();
}

class _FillingLogoLoaderState extends State<FillingLogoLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          // Background: Pale/Ghost version
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              'assets/FranchiseIcon.png', // Assuming this is the correct asset path per user request
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
              // color: Colors.grey, // Removed to show original color but pale
              // colorBlendMode: BlendMode.srcIn,
            ),
          ),
          // Foreground: Filling version
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                clipper: _FillingClipper(_controller.value),
                child: Image.asset(
                  'assets/FranchiseIcon.png',
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FillingClipper extends CustomClipper<Rect> {
  final double progress;

  _FillingClipper(this.progress);

  @override
  Rect getClip(Size size) {
    // Fill from bottom to top
    return Rect.fromLTRB(
      0,
      size.height * (1 - progress),
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(_FillingClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
