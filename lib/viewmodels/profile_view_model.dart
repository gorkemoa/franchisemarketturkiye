import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';
import 'package:franchisemarketturkiye/models/customer.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Customer? _customer;
  Customer? get customer => _customer;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.getMe();
      if (result.isSuccess) {
        if (result.data!.success) {
          _customer = result.data!.data?.customer;
        } else {
          _errorMessage = 'Profil bilgileri alınamadı';
        }
      } else {
        _errorMessage = result.error;
      }
    } catch (e) {
      _errorMessage = 'Beklenmedik bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _customer = null;
    notifyListeners();
  }
}
