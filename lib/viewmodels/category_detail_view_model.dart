import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/models/category.dart';
import 'package:franchisemarketturkiye/services/blog_service.dart';

class CategoryDetailViewModel extends ChangeNotifier {
  final BlogService _blogService;
  final Category category;

  CategoryDetailViewModel({required this.category, BlogService? blogService})
    : _blogService = blogService ?? BlogService();

  List<Blog> _blogs = [];
  List<Blog> get blogs => _blogs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  Future<void> init() async {
    await fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _blogService.getBlogsByCategory(category.link);

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _blogs = result.data!.items;
      _totalCount = result.data!.count;
    } else {
      _errorMessage = result.error ?? 'Unknown error occurred';
    }
    notifyListeners();
  }
}
