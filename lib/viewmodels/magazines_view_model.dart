import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/magazine.dart';
import 'package:franchisemarketturkiye/services/magazine_service.dart';

class MagazinesViewModel extends ChangeNotifier {
  final MagazineService _magazineService = MagazineService();

  List<Magazine> _magazines = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _nextCursor;
  bool _hasMore = true;

  List<Magazine> get magazines => _magazines;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> fetchMagazines({bool isRefresh = false}) async {
    if (isRefresh) {
      _nextCursor = null;
      _magazines = [];
      _hasMore = true;
    }

    if (!_hasMore && !isRefresh) return;

    if (_nextCursor == null) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    final result = await _magazineService.getMagazines(cursor: _nextCursor);

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      if (_nextCursor == null) {
        _magazines = response.data.items;
      } else {
        _magazines.addAll(response.data.items);
      }

      _nextCursor = response.meta.nextCursor;
      _hasMore = response.meta.hasMore;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    await fetchMagazines();
  }
}
