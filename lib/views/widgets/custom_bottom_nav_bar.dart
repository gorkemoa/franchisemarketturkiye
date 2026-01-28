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
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildNavItem(0, 'nav_0_sef.svg', 'nav_0_sel.svg'),
              ),
              Expanded(
                child: _buildNavItem(1, 'nav_1_sef.svg', 'nav_1_sel.svg'),
              ),
              const SizedBox(width: 70), // Space for the floating action button
              Expanded(
                child: _buildNavItem(3, 'nav_3_sef.svg', 'nav_3_sel.svg'),
              ),
              Expanded(
                child: _buildNavItem(4, 'nav_4_sef.svg', 'nav_4_sel.svg'),
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
        color: Colors.transparent, // Ensure it catches taps
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SvgPicture.asset(path, fit: BoxFit.contain),
      ),
    );
  }
}
