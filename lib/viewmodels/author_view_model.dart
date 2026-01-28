import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/author.dart';
import 'package:franchisemarketturkiye/services/author_service.dart';
import 'package:franchisemarketturkiye/core/extensions/turkish_string_extensions.dart';

class AuthorViewModel extends ChangeNotifier {
  final AuthorService _authorService;

  AuthorViewModel({AuthorService? authorService})
    : _authorService = authorService ?? AuthorService();

  List<Author> _authors = [];
  String _searchQuery = '';

  List<Author> get authors {
    if (_searchQuery.isEmpty) return _authors;
    return _authors
        .where((a) => a.fullname.turkishContains(_searchQuery))
        .toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _nextCursor;

  Future<void> fetchAuthors() async {
    _isLoading = true;
    _errorMessage = null;
    _authors = [];
    notifyListeners();

    final result = await _authorService.getAuthors();

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _authors = result.data!.data.items;
      _hasMore = result.data!.meta.hasMore;
      _nextCursor = result.data!.meta.nextCursor;
    } else {
      _errorMessage = result.error ?? 'Veriler yüklenirken bir hata oluştu';
    }
    notifyListeners();
  }

  Future<void> loadMoreAuthors() async {
    if (_isLoading || !_hasMore || _nextCursor == null) return;

    _isLoading = true;
    notifyListeners();

    final result = await _authorService.getAuthors(cursor: _nextCursor);

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _authors.addAll(result.data!.data.items);
      _hasMore = result.data!.meta.hasMore;
      _nextCursor = result.data!.meta.nextCursor;
    }
    notifyListeners();
  }
}
