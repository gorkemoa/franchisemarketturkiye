import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/author.dart';
import 'package:franchisemarketturkiye/viewmodels/author_detail_view_model.dart';
import 'package:franchisemarketturkiye/views/home/blog_list_item.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';

class AuthorDetailView extends StatefulWidget {
  final int authorId;
  final Author? author;

  const AuthorDetailView({super.key, required this.authorId, this.author});

  @override
  State<AuthorDetailView> createState() => _AuthorDetailViewState();
}

class _AuthorDetailViewState extends State<AuthorDetailView> {
  late final AuthorDetailViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = AuthorDetailViewModel(
      authorId: widget.authorId,
      author: widget.author,
    );
    _viewModel.init();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_viewModel.isLoading &&
        _viewModel.hasMore) {
      _viewModel.loadMoreBlogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final author = _viewModel.author;

        return GlobalScaffold(
          showBackButton: true,
          showSearch: true,
          onSearchChanged: (value) {
            _viewModel.setSearchQuery(value);
          },
          body: RefreshIndicator(
            onRefresh: _viewModel.fetchAuthorBlogs,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                if (author != null)
                  SliverToBoxAdapter(child: _buildAuthorHeader(author)),
                if (_viewModel.isLoading && _viewModel.blogs.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_viewModel.errorMessage != null &&
                    _viewModel.blogs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_viewModel.errorMessage!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _viewModel.init,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_viewModel.blogs.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Yazara ait aradığınız kriterlere uygun yazı bulunamadı.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontFamily: 'BioSans',
                          ),
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
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BlogListItem(blog: _viewModel.blogs[index]),
                        );
                      }, childCount: _viewModel.blogs.length),
                    ),
                  ),
                if (_viewModel.isLoading && _viewModel.blogs.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthorHeader(Author author) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
              image: DecorationImage(
                image: NetworkImage(author.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            author.fullname,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'BioSans',
              color: Colors.black,
            ),
          ),
          if (author.title.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              author.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (author.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              author.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                author.fullname.replaceAll('i', 'İ').toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                  fontFamily: 'BioSans',
                ),
              ),
              Text(
                ' YAZILARI'.replaceAll('i', 'İ').toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: 0.5,
                  fontFamily: 'BioSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(width: 40, height: 2, color: AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }
}
