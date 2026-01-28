import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/author.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/services/author_service.dart';

class AuthorDetailViewModel extends ChangeNotifier {
  final AuthorService _authorService;
  final int authorId;
  Author? _author;

  AuthorDetailViewModel({
    required this.authorId,
    Author? author,
    AuthorService? authorService,
  }) : _author = author,
       _authorService = authorService ?? AuthorService();

  Author? get author => _author;

  List<Blog> _blogs = [];
  List<Blog> get blogs => _blogs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _nextCursor;

  Future<void> init() async {
    if (_author == null) {
      await fetchAuthorDetail();
    }
    await fetchAuthorBlogs();
  }

  Future<void> fetchAuthorDetail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authorService.getAuthorDetail(authorId);

    if (result.isSuccess && result.data != null) {
      _author = result.data;
    } else {
      _errorMessage =
          result.error ?? 'Yazar bilgileri yüklenirken bir hata oluştu';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAuthorBlogs() async {
    if (_author == null && _isLoading)
      return; // Wait for detail if it's loading

    _isLoading = true;
    _errorMessage = null;
    _blogs = [];
    notifyListeners();

    final result = await _authorService.getAuthorBlogs(authorId);

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _blogs = result.data!.data.items;
      _hasMore = result.data!.meta.hasMore;
      _nextCursor = result.data!.meta.nextCursor;
    } else {
      _errorMessage = result.error ?? 'Yazılar yüklenirken bir hata oluştu';
    }
    notifyListeners();
  }

  Future<void> loadMoreBlogs() async {
    if (_isLoading || !_hasMore || _nextCursor == null) return;

    _isLoading = true;
    notifyListeners();

    final result = await _authorService.getAuthorBlogs(
      authorId,
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
