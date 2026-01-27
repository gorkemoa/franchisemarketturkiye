import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/models/category.dart';
import 'package:franchisemarketturkiye/services/category_service.dart';

class CategoryDetailViewModel extends ChangeNotifier {
  final CategoryService _categoryService;
  Category? _category;
  final int? _categoryId;

  CategoryDetailViewModel({
    Category? category,
    int? categoryId,
    CategoryService? categoryService,
  }) : _category = category,
       _categoryId = categoryId ?? category?.id,
       _categoryService = categoryService ?? CategoryService();

  Category? get category => _category;

  List<Blog> _blogs = [];
  List<Blog> get blogs => _blogs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  Future<void> init() async {
    if (_category == null && _categoryId != null) {
      await fetchCategory();
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
}
