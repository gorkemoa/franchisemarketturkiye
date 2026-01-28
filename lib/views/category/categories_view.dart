import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/viewmodels/categories_view_model.dart';
import 'package:franchisemarketturkiye/views/category/category_detail_view.dart';

class CategoriesView extends StatefulWidget {
  final CategoriesViewModel? viewModel;
  const CategoriesView({super.key, this.viewModel});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  late final CategoriesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? CategoriesViewModel();
    if (widget.viewModel == null) {
      _viewModel.init();
    }
  }

  String _getCategoryIcon(String name) {
    // Normalizing name for mapping
    final normalized = name.toLowerCase();
    if (normalized.contains('genel')) return 'assets/category_icons/Frame.svg';
    if (normalized.contains('franchise'))
      return 'assets/category_icons/Frame (1).svg';
    if (normalized.contains('sektörel'))
      return 'assets/category_icons/Frame (2).svg';
    if (normalized.contains('girişimcilik'))
      return 'assets/category_icons/Frame (3).svg';
    if (normalized.contains('teknoloji'))
      return 'assets/category_icons/Frame (4).svg';
    if (normalized.contains('sosyal sorumluluk'))
      return 'assets/category_icons/Frame (5).svg';
    if (normalized.contains('atama'))
      return 'assets/category_icons/Frame (6).svg';
    if (normalized.contains('restoran'))
      return 'assets/category_icons/Frame (7).svg';

    // Default to first icon if no match
    return 'assets/category_icons/Frame.svg';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_viewModel.errorMessage != null) {
          return Center(child: Text(_viewModel.errorMessage!));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('KATEGORİLER'),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _viewModel.categories.length,
                itemBuilder: (context, index) {
                  final category = _viewModel.categories[index];

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryDetailView(category: category),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              _getCategoryIcon(category.name),
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name
                                        .replaceAll('i', 'İ')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'BioSans',
                                    ),
                                  ),
                                  if (category.description != null &&
                                      category.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      category.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'BioSans',
            ),
          ),
          const SizedBox(height: 4),
          Container(width: 50, height: 2, color: AppTheme.primaryColor),
        ],
      ),
    );
  }
}
