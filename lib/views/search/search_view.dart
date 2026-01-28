import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/viewmodels/search_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/categories_view_model.dart';
import 'package:franchisemarketturkiye/views/home/blog_list_item.dart';
import 'package:franchisemarketturkiye/views/blog/blog_detail_view.dart';
import 'package:franchisemarketturkiye/models/blog.dart';

class SearchView extends StatefulWidget {
  final SearchViewModel viewModel;
  final CategoriesViewModel categoriesViewModel;

  const SearchView({
    super.key,
    required this.viewModel,
    required this.categoriesViewModel,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.text = widget.viewModel.searchQuery;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.viewModel.loadMore();
    }
  }

  void _handleBlogTap(Blog blog) {
    widget.viewModel.addToRecentlyViewed(blog);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BlogDetailView(blogId: blog.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.viewModel,
        widget.categoriesViewModel,
      ]),
      builder: (context, child) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              _buildSearchHeader(context),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.05), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ne aramıştınız?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              fontFamily: 'BioSans',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildCategoryChips(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          widget.viewModel.onSearchChanged(val);
          setState(() {});
        },
        style: const TextStyle(
          fontFamily: 'BioSans',
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Yazı, haber ve franchise...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'BioSans',
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    widget.viewModel.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    if (widget.categoriesViewModel.isLoading) {
      return const SizedBox(height: 32);
    }

    final categories = widget.categoriesViewModel.categories;
    if (categories.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.take(10).map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                _searchController.text = category.name;
                widget.viewModel.onSearchChanged(category.name);
                setState(() {});
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'BioSans',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.viewModel.isLoading && widget.viewModel.blogs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.searchQuery.isEmpty) {
      return _buildRecommendations();
    }

    if (widget.viewModel.blogs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Sonuç bulunamadı',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontFamily: 'BioSans',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => widget.viewModel.search(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount:
            widget.viewModel.blogs.length + (widget.viewModel.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < widget.viewModel.blogs.length) {
            final blog = widget.viewModel.blogs[index];
            return BlogListItem(blog: blog, onTap: () => _handleBlogTap(blog));
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Widget _buildRecommendations() {
    final showRecent = widget.viewModel.recentlyViewed.isNotEmpty;
    final blogs = showRecent
        ? widget.viewModel.recentlyViewed
        : widget.viewModel.recommendedBlogs;
    final title = showRecent
        ? 'Son Görüntülemeleriniz'
        : 'Sizin İçin Seçtiklerimiz';

    if (blogs.isEmpty && widget.viewModel.isLoadingRecommended) {
      return const Center(child: CircularProgressIndicator());
    }

    if (blogs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'BioSans',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              if (showRecent)
                TextButton(
                  onPressed: () => widget.viewModel.clearRecentlyViewed(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Temizle',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'BioSans',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: blogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final blog = blogs[index];
                return BlogListItem(
                  blog: blog,
                  onTap: () => _handleBlogTap(blog),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
