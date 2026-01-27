import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 75, // Increased height to accommodate baked-in labels
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildNavItem(0, 'nav_0_def.svg', 'nav_0_sel.svg'),
                  ),
                  Expanded(
                    child: _buildNavItem(1, 'nav_1_def.svg', 'nav_1_sel.svg'),
                  ),
                  const SizedBox(width: 80), // Space for the middle button
                  Expanded(
                    child: _buildNavItem(3, 'nav_3_def.svg', 'nav_3_sel.svg'),
                  ),
                  Expanded(
                    child: _buildNavItem(4, 'nav_4_def.svg', 'nav_4_sel.svg'),
                  ),
                ],
              ),
              Positioned(
                top: -35, // Floating the middle button higher
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => onTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: SizedBox(
                      width: 85,
                      height: 85,
                      child: SvgPicture.asset(
                        'assets/bottombar_icons/nav_middle.svg',
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) => Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.home, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconName, String? selectedIconName) {
    final isSelected = currentIndex == index;
    final path =
        'assets/bottombar_icons/${isSelected ? (selectedIconName ?? iconName) : iconName}';

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SvgPicture.asset(
          path,
          fit: BoxFit.contain,
          // Removed height/width constraints to let the SVG scale naturally within the Container
          placeholderBuilder: (context) => const SizedBox(
            width: 32,
            height: 32,
            child: Icon(Icons.error, size: 24, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
