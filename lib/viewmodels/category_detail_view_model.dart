import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/models/category.dart';
import 'package:franchisemarketturkiye/services/blog_service.dart';
import 'package:franchisemarketturkiye/services/category_service.dart';

class CategoryDetailViewModel extends ChangeNotifier {
  final CategoryService _categoryService;
  final BlogService _blogService;
  Category? _category;
  final int? _categoryId;

  CategoryDetailViewModel({
    Category? category,
    int? categoryId,
    CategoryService? categoryService,
    BlogService? blogService,
  }) : _category = category,
       _categoryId = categoryId ?? category?.id,
       _categoryService = categoryService ?? CategoryService(),
       _blogService = blogService ?? BlogService();

  Category? get category => _category;

  List<Blog> _blogs = [];
  String _searchQuery = '';

  List<Blog> get blogs {
    if (_searchQuery.isEmpty) return _blogs;
    return _blogs.where((blog) {
      final title = blog.title.toLowerCase();
      final description = blog.description.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _nextCursor;

  Future<void> init() async {
    if (_categoryId != null) {
      await fetchCategory();
    }
    if (_category != null) {
      await fetchBlogs();
    }
  }

  Future<void> fetchCategory() async {
    if (_categoryId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _categoryService.getCategoryById(_categoryId);

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _category = result.data;
    } else {
      _errorMessage = result.error ?? 'Unknown error occurred';
    }
    notifyListeners();
  }

  Future<void> fetchBlogs() async {
    if (_category == null) return;

    _isLoading = true;
    _errorMessage = null;
    _blogs = [];
    notifyListeners();

    final result = await _blogService.getBlogsByCategory(_category!.id);

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _blogs = result.data!.data.items;
      _totalCount = result.data!.meta.totalItems;
      _hasMore = result.data!.meta.hasMore;
      _nextCursor = result.data!.meta.nextCursor;
    } else {
      _errorMessage = result.error ?? 'Unknown error occurred';
    }
    notifyListeners();
  }

  Future<void> loadMoreBlogs() async {
    if (_isLoading || !_hasMore || _category == null || _nextCursor == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _blogService.getBlogsByCategory(
      _category!.id,
      cursor: _nextCursor,
    );

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _blogs.addAll(result.data!.data.items);
      _hasMore = result.data!.meta.hasMore;
      _nextCursor = result.data!.meta.nextCursor;
    }
    notifyListeners();
  }
}
