import 'dart:async';
import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_constants.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/services/blog_service.dart';

class SearchViewModel extends ChangeNotifier {
  final BlogService _blogService = BlogService();

  List<Blog> _blogs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _offset = 0;
  bool _hasMore = false;
  String _searchQuery = '';
  Timer? _debounce;

  List<Blog> get blogs => _blogs;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  void onSearchChanged(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery.isNotEmpty) {
        search(isRefresh: true);
      } else {
        _blogs = [];
        _errorMessage = null;
        _isLoading = false;
        _hasMore = false;
        notifyListeners();
      }
    });
  }

  Future<void> search({bool isRefresh = false}) async {
    if (_searchQuery.isEmpty) return;

    if (isRefresh) {
      _offset = 0;
      _blogs = [];
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    final result = await _blogService.searchBlogs(
      _searchQuery,
      offset: _offset,
      limit: AppConstants.defaultLimit,
    );

    if (result.isSuccess && result.data != null) {
      final searchData = result.data!.data;
      if (isRefresh) {
        _blogs = searchData.items;
      } else {
        _blogs.addAll(searchData.items);
      }
      _offset = _blogs.length;
      _hasMore = searchData.hasMore;
      _errorMessage = null;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    await search();
  }

  void retry() {
    search(isRefresh: true);
  }

  void clear() {
    _searchQuery = '';
    _blogs = [];
    _offset = 0;
    _hasMore = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
