import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/viewmodels/search_view_model.dart';
import 'package:franchisemarketturkiye/views/home/blog_list_item.dart';

class SearchView extends StatefulWidget {
  final SearchViewModel viewModel;

  const SearchView({super.key, required this.viewModel});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        if (widget.viewModel.searchQuery.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: AppTheme.textTertiary),
                SizedBox(height: 16),
                Text(
                  'Aramaya başlayın',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontFamily: 'BioSans',
                  ),
                ),
              ],
            ),
          );
        }

        if (widget.viewModel.isLoading && widget.viewModel.blogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.viewModel.errorMessage != null &&
            widget.viewModel.blogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.viewModel.errorMessage!,
                  style: const TextStyle(color: AppTheme.primaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.viewModel.retry,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        if (widget.viewModel.blogs.isEmpty) {
          return const Center(
            child: Text(
              'Sonuç bulunamadı',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontFamily: 'BioSans',
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => widget.viewModel.search(isRefresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount:
                widget.viewModel.blogs.length +
                (widget.viewModel.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < widget.viewModel.blogs.length) {
                return BlogListItem(blog: widget.viewModel.blogs[index]);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );
      },
    );
  }
}
