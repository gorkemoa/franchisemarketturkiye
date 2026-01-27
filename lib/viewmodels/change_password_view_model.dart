import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newPasswordConfirmController =
      TextEditingController();

  Future<bool> updatePassword() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        newPasswordConfirmController.text.isEmpty) {
      _errorMessage = 'Lütfen tüm alanları doldurunuz.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (newPasswordController.text != newPasswordConfirmController.text) {
      _errorMessage = 'Yeni şifreler uyuşmuyor.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (newPasswordController.text.length < 6) {
      _errorMessage = 'Şifre en az 6 karakter olmalıdır.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final result = await _authService.updatePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (result.isSuccess) {
        _successMessage = 'Şifreniz başarıyla güncellendi.';
        currentPasswordController.clear();
        newPasswordController.clear();
        newPasswordConfirmController.clear();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Beklenmedik bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    newPasswordConfirmController.dispose();
    super.dispose();
  }
}
