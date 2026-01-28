import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/magazine.dart';
import 'package:franchisemarketturkiye/services/magazine_service.dart';

class MagazineDetailViewModel extends ChangeNotifier {
  final MagazineService _magazineService = MagazineService();
  final int magazineId;

  Magazine? _magazine;
  bool _isLoading = false;
  String? _errorMessage;

  Magazine? get magazine => _magazine;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MagazineDetailViewModel({required this.magazineId});

  Future<void> fetchMagazineDetail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _magazineService.getMagazineDetail(magazineId);

    if (result.isSuccess && result.data != null) {
      _magazine = result.data;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }
}
