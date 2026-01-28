import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/franchise.dart';
import 'package:franchisemarketturkiye/viewmodels/franchise_detail_view_model.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';

class FranchiseDetailView extends StatefulWidget {
  final int franchiseId;

  const FranchiseDetailView({super.key, required this.franchiseId});

  @override
  State<FranchiseDetailView> createState() => _FranchiseDetailViewState();
}

class _FranchiseDetailViewState extends State<FranchiseDetailView> {
  late final FranchiseDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FranchiseDetailViewModel(franchiseId: widget.franchiseId);
    _viewModel.fetchFranchiseDetail();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return GlobalScaffold(
          title: Text(
            _viewModel.franchise?.title ?? 'Yükleniyor...',
            style: const TextStyle(
              fontFamily: 'BioSans',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          showBackButton: true,
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_viewModel.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _viewModel.fetchFranchiseDetail(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final franchise = _viewModel.franchise;
    if (franchise == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(40),
            color: const Color(0xFFF9F9F9),
            height: 250,
            child: Image.network(
              franchise.logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.business, size: 60, color: Colors.grey),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                _buildInfoCard(franchise),
                const SizedBox(height: 16),

                // Action Button
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implementation for application
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Hemen Başvurun',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                HtmlWidget(
                  franchise.description,
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Franchise franchise) {
    // Filter options where value is not empty
    final activeOptions = franchise.options
        .where((opt) => opt.value.trim().isNotEmpty)
        .toList();

    if (activeOptions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: activeOptions.map((opt) => _buildOptionRow(opt)).toList(),
      ),
    );
  }

  Widget _buildOptionRow(FranchiseOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(4),
            child: SvgPicture.asset(
              'assets/franchise_icon/${option.icon}',
              placeholderBuilder: (context) => option.iconUrl.endsWith('.svg')
                  ? SvgPicture.network(
                      option.iconUrl,
                      placeholderBuilder: (context) => const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                    )
                  : Image.network(
                      option.iconUrl,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
