import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/services/blog_service.dart';

class BlogDetailViewModel extends ChangeNotifier {
  final BlogService _blogService;
  final int blogId;

  BlogDetailViewModel({required this.blogId, BlogService? blogService})
    : _blogService = blogService ?? BlogService();

  Blog? _blog;
  Blog? get blog => _blog;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    await fetchBlog();
  }

  Future<void> fetchBlog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _blogService.getBlogById(blogId);

    _isLoading = false;
    if (result.isSuccess) {
      _blog = result.data;
    } else {
      _errorMessage = result.error;
    }
    notifyListeners();
  }
}
