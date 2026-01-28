import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/franchise.dart';
import 'package:franchisemarketturkiye/services/franchise_service.dart';

class FranchiseDetailViewModel extends ChangeNotifier {
  final FranchiseService _franchiseService = FranchiseService();
  final int franchiseId;

  Franchise? _franchise;
  bool _isLoading = false;
  String? _errorMessage;

  Franchise? get franchise => _franchise;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FranchiseDetailViewModel({required this.franchiseId});

  Future<void> fetchFranchiseDetail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _franchiseService.getFranchiseDetail(franchiseId);

    if (result.isSuccess && result.data != null) {
      _franchise = result.data!.data.item;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }
}
