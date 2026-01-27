import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> login() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      _isLoading = false;
      if (result.isSuccess) {
        if (result.data!.success) {
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';
        }
      } else {
        _errorMessage = result.error;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Bir hata oluştu: $e';
    }

    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
