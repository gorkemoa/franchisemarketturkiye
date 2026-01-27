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
            _buildItem(context, 'Kebo'),
            const SizedBox(height: 24),
            _buildItem(context, 'Öküz Burger'),
            const SizedBox(height: 24),
            _buildItem(context, 'She Accessories'),
            const SizedBox(height: 24),
            _buildItem(context, 'ÇÖPS'),
            const SizedBox(height: 24),
            _buildItem(context, 'John Filippo Pizza'),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String title) {
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
          child: ClipRRect(borderRadius: BorderRadius.circular(4)),
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
