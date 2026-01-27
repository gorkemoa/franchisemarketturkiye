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
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200 &&
              !_viewModel.isLoading &&
              _viewModel.hasMore) {
            _viewModel.loadMoreBlogs();
          }
          return true;
        },
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading && _viewModel.category == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_viewModel.errorMessage != null &&
                _viewModel.category == null) {
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
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'ANA SAYFA',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            Text(
                              category.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Title & Icon Row
                        Row(
                          children: [
                            if (category.imageUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: category.imageUrl!.endsWith('.svg')
                                    ? SvgPicture.network(
                                        category.imageUrl!,
                                        width: 32,
                                        height: 32,
                                      )
                                    : Image.network(
                                        category.imageUrl!,
                                        width: 32,
                                        height: 32,
                                      ),
                              ),
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'BioSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Description
                        if (category.description != null)
                          Text(
                            category.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_viewModel.totalCount > 0 ? _viewModel.totalCount : (category.count ?? 0)} İÇERİK',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Blog List
                if (_viewModel.blogs.isEmpty && _viewModel.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (_viewModel.errorMessage != null &&
                    _viewModel.blogs.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_viewModel.errorMessage!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _viewModel.fetchBlogs,
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

                // Load More Indicator
                if (_viewModel.isLoading && _viewModel.blogs.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }
}
