import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class TagBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final bool isDark;

  const TagBadge({
    super.key,
    required this.text,
    this.color,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.3)
            : (color?.withOpacity(0.08) ?? AppTheme.tagBackground),
        border: !isDark
            ? Border.all(color: baseColor.withOpacity(0.0), width: 0.5)
            : null,
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : baseColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
