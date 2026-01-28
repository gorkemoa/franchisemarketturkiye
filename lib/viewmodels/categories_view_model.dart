import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/category.dart';
import 'package:franchisemarketturkiye/services/category_service.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';

  List<Category> get categories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> init({int selected = 0}) async {
    await fetchCategories(selected: selected);
  }

  Future<void> fetchCategories({int selected = 0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _categoryService.getCategories(selected: selected);

    if (result.isSuccess) {
      _categories = List<Category>.from(result.data ?? []);
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }
}
