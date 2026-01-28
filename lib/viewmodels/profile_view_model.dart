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
            phoneController.text = (_customer!.phone?.isNotEmpty == true)
                ? _customer!.phone!
                : '0';
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

  Future<bool> updateProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        firstname: firstNameController.text.trim(),
        lastname: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        newsletter: _newsletter ? 1 : 0,
      );

      if (result.isSuccess) {
        await loadProfile(); // Refresh profile data
        return true;
      } else {
        _errorMessage = result.error;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Beklenmedik bir hata oluştu: $e';
      return false;
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
