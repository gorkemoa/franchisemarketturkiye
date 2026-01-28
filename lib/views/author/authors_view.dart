import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/author.dart';
import 'package:franchisemarketturkiye/viewmodels/author_view_model.dart';

import 'package:franchisemarketturkiye/views/author/author_detail_view.dart';

class AuthorsView extends StatefulWidget {
  final AuthorViewModel? viewModel;
  const AuthorsView({super.key, this.viewModel});

  @override
  State<AuthorsView> createState() => _AuthorsViewState();
}

class _AuthorsViewState extends State<AuthorsView> {
  late final AuthorViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AuthorViewModel();
    if (widget.viewModel == null) {
      _viewModel.fetchAuthors();
    }
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
      _viewModel.loadMoreAuthors();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return RefreshIndicator(
          onRefresh: _viewModel.fetchAuthors,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YAZARLAR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 0.5,
                          fontFamily: 'BioSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 2,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              if (_viewModel.isLoading && _viewModel.authors.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_viewModel.errorMessage != null &&
                  _viewModel.authors.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_viewModel.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _viewModel.fetchAuthors,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_viewModel.authors.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Aradığınız kriterlere uygun yazar bulunamadı.',
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
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return AuthorCard(author: _viewModel.authors[index]);
                    }, childCount: _viewModel.authors.length),
                  ),
                ),
              if (_viewModel.isLoading && _viewModel.authors.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }
}

class AuthorCard extends StatelessWidget {
  final Author author;

  const AuthorCard({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AuthorDetailView(authorId: author.id, author: author),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  author.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[100],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                author.fullname.replaceAll('i', 'İ').toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'BioSans',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                author.title,
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
