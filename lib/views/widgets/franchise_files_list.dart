import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class FranchiseFilesList extends StatelessWidget {
  const FranchiseFilesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'FRANCHISE',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: AppTheme.primaryColor),
                    ),
                    TextSpan(
                      text: ' DOSYALARI',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to full list
                },
                child: Text(
                  'Tümünü Listele',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.borderColor),
        const SizedBox(height: 16),
        // List
        Column(
          children: [
            _buildItem(context, 'Kebo', 'assets/kebo.png'),
            const SizedBox(height: 24),
            _buildItem(context, 'Öküz Burger', 'assets/okuz_burger.png'),
            const SizedBox(height: 24),
            _buildItem(context, 'She Accessories', 'assets/she.png'),
            const SizedBox(height: 24),
            _buildItem(context, 'ÇÖPS', 'assets/cops.png'),
            const SizedBox(height: 24),
            _buildItem(
              context,
              'John Filippo Pizza',
              'assets/john_filippo.png',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String title, String imagePath) {
    return Row(
      children: [
        // Logo Placeholder
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    title[0],
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Title
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
