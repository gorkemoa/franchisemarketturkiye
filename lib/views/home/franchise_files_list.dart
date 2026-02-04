import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/franchise.dart';
import 'package:franchisemarketturkiye/views/franchise/franchise_detail_view.dart';

class FranchiseFilesList extends StatelessWidget {
  final List<Franchise> franchises;
  final VoidCallback onListAll;

  const FranchiseFilesList({
    super.key,
    required this.franchises,
    required this.onListAll,
  });

  @override
  Widget build(BuildContext context) {
    if (franchises.isEmpty) return const SizedBox.shrink();

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
                onTap: onListAll,
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
        if (MediaQuery.of(context).size.width >= 600)
          Wrap(
            spacing: 16,
            runSpacing: 24,
            children: franchises.take(6).map((franchise) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 2,
                child: _buildItem(context, franchise),
              );
            }).toList(),
          )
        else
          Column(
            children: franchises.take(5).map((franchise) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildItem(context, franchise),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, Franchise franchise) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FranchiseDetailView(franchiseId: franchise.id),
          ),
        );
      },
      child: Row(
        children: [
          // Logo
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: ClipRRect(
              child: Image.network(
                franchise.logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.business, size: 16, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text(
              franchise.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
