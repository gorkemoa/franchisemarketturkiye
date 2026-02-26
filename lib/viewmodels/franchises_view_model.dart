import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/franchise.dart';
import 'package:franchisemarketturkiye/models/franchise_category.dart';
import 'package:franchisemarketturkiye/services/franchise_service.dart';

class FranchisesViewModel extends ChangeNotifier {
  static final FranchisesViewModel instance = FranchisesViewModel._internal();
  factory FranchisesViewModel() => instance;
  FranchisesViewModel._internal();

  final FranchiseService _franchiseService = FranchiseService();

  List<Franchise> _franchises = [];
  List<FranchiseCategory> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  bool _isLoadingCategories = false;
  String? _errorMessage;
  int _offset = 0;
  bool _hasMore = true;
  String _searchQuery = '';
  int? _categoryId;

  List<Franchise> get franchises => _franchises;
  List<FranchiseCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  bool get isLoadingCategories => _isLoadingCategories;
  int? get categoryId => _categoryId;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _offset = 0;
    _hasMore = true;
    fetchFranchises(isSearch: true);
  }

  void setCategoryId(int? categoryId) {
    if (_categoryId == categoryId) return;
    _categoryId = categoryId;
    _offset = 0;
    _franchises = [];
    _hasMore = true;
    fetchFranchises();
  }

  Future<void> fetchFranchises({
    bool isRefresh = false,
    bool isSearch = false,
  }) async {
    if (isRefresh) {
      _offset = 0;
      _franchises = [];
      _hasMore = true;
    }

    if (!_hasMore && !isRefresh) return;

    if (isSearch) {
      _isSearching = true;
    } else if (_offset == 0) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    final result = await _franchiseService.getFranchises(
      offset: _offset,
      categoryId: _categoryId,
      q: _searchQuery,
    );

    if (result.isSuccess && result.data != null) {
      final newFranchises = result.data!.data.items;
      if (_offset == 0) {
        _franchises = newFranchises;
      } else {
        _franchises.addAll(newFranchises);
      }

      _offset += newFranchises.length;
      _hasMore = _franchises.length < result.data!.data.total;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    _isLoadingMore = false;
    _isSearching = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    final result = await _franchiseService.getFranchiseCategories();

    if (result.isSuccess && result.data != null) {
      _categories = result.data!.data.items;
    }

    _isLoadingCategories = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    await fetchFranchises();
  }
}
