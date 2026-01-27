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

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _newsletter = false;
  bool get newsletter => _newsletter;

  void setNewsletter(bool? value) {
    _newsletter = value ?? false;
    notifyListeners();
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
          if (_customer != null) {
            firstNameController.text = _customer!.firstname ?? '';
            lastNameController.text = _customer!.lastname ?? '';
            phoneController.text = _customer!.phone ?? '';
            emailController.text = _customer!.email ?? '';
            _newsletter = _customer!.newsletter == "1";
          }
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

  Future<void> updateProfile() async {
    // Implement update logic here
    // For now, just show a simulation or print
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _customer = null;
    notifyListeners();
  }
}
