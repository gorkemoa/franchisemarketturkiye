import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/category.dart';
import 'package:franchisemarketturkiye/viewmodels/category_detail_view_model.dart';
import 'package:franchisemarketturkiye/views/home/blog_list_item.dart';
import 'package:franchisemarketturkiye/views/home/tag_badge.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';

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

class _CategoryDetailViewState extends State<CategoryDetailView>
    with SingleTickerProviderStateMixin {
  late final CategoryDetailViewModel _viewModel;
  late final AnimationController _searchAnimationController;
  late final Animation<double> _searchHeightAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _viewModel = CategoryDetailViewModel(
      category: widget.category,
      categoryId: widget.categoryId,
    );
    _viewModel.init();

    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchHeightAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
        _viewModel.setSearchQuery('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final category = _viewModel.category;

        return GlobalScaffold(
          showBackButton: true,
          actions: [
            IconButton(
              icon: Icon(
                _isSearchVisible ? Icons.close : Icons.search,
                color: Colors.black,
              ),
              onPressed: _toggleSearch,
            ),
          ],
          body: Column(
            children: [
              SizeTransition(
                sizeFactor: _searchHeightAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _viewModel.setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Arama yapın...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200 &&
                        !_viewModel.isLoading &&
                        _viewModel.hasMore) {
                      _viewModel.loadMoreBlogs();
                    }
                    return true;
                  },
                  child: _buildBody(category),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(Category? category) {
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
                        'KATEGORİLER',
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
                      category.name.replaceAll('i', 'İ').toUpperCase(),
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
                TagBadge(
                  text:
                      '${_viewModel.totalCount > 0 ? _viewModel.totalCount : (category.count ?? 0)} İÇERİK',
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
        else if (_viewModel.errorMessage != null && _viewModel.blogs.isEmpty)
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
        else if (_viewModel.blogs.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'Aradığınız kriterlere uygun içerik bulunamadı.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
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
  }
}
