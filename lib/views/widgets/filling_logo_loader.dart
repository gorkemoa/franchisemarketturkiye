import 'package:flutter/material.dart';

class FillingLogoLoader extends StatelessWidget {
  final double size;
  final double progress; // 0.0 to 1.0

  const FillingLogoLoader({
    super.key,
    this.size = 100.0,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background: Pale/Ghost version
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              'assets/FranchiseIcon.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
          // Foreground: Filling version
          ClipRect(
            clipper: _FillingClipper(progress),
            child: Image.asset(
              'assets/FranchiseIcon.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
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
      size.height * (1 - progress.clamp(0.0, 1.0)),
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(_FillingClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
