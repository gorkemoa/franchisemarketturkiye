import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/category.dart';
import 'package:franchisemarketturkiye/viewmodels/category_detail_view_model.dart';
import 'package:franchisemarketturkiye/views/home/blog_list_item.dart';
import 'package:franchisemarketturkiye/views/auth/login_view.dart';

class CategoryDetailView extends StatefulWidget {
  final Category? category;
  final int? categoryId;

  const CategoryDetailView({super.key, this.category, this.categoryId})
    : assert(
        category != null || categoryId != null,
        'Either category or categoryId must be provided',
      );

  @override
  State<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView> {
  late final CategoryDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CategoryDetailViewModel(
      category: widget.category,
      categoryId: widget.categoryId,
    );
    _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/logo.svg',
          height: 30,
          placeholderBuilder: (context) => const Text('FRANCHISE MARKET'),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
            icon: Container(
              color: AppTheme.primaryColor,
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading && _viewModel.category == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null && _viewModel.category == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _viewModel.init,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final category = _viewModel.category;
          if (category == null) {
            return const Center(child: Text('Kategori bulunamadı.'));
          }

          return CustomScrollView(
            slivers: [
              // Breadcrumb & Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb
                      Row(
                        children: [
                          const Text(
                            'Ana Sayfa',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          Text(
                            category.name,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      if (category.description != null)
                        Text(
                          category.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Count
                      Text(
                        '${_viewModel.totalCount > 0 ? _viewModel.totalCount : (category.count ?? 0)} gönderi',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Blog List
              if (_viewModel.isLoading)
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_viewModel.errorMessage != null)
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_viewModel.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _viewModel.init,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BlogListItem(blog: _viewModel.blogs[index]),
                      );
                    }, childCount: _viewModel.blogs.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
