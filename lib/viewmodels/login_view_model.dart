import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _lastStatusCode;
  int? get lastStatusCode => _lastStatusCode;

  bool _isLogin;
  bool get isLogin => _isLogin;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Register specific controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();

  LoginViewModel({bool initialIsLogin = true}) : _isLogin = initialIsLogin {
    phoneController.text = '0';
  }

  bool _newsletter = false;
  bool get newsletter => _newsletter;

  bool _termsAccepted = false;
  bool get termsAccepted => _termsAccepted;

  void toggleAuthMode() {
    _isLogin = !_isLogin;
    _errorMessage = null;
    notifyListeners();
  }

  void setNewsletter(bool? value) {
    _newsletter = value ?? false;
    notifyListeners();
  }

  void setTermsAccepted(bool? value) {
    _termsAccepted = value ?? false;
    notifyListeners();
  }

  Future<bool> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _errorMessage = 'E-posta ve şifre alanları boş bırakılamaz.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      _isLoading = false;
      _lastStatusCode = result.statusCode;
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

  Future<bool> register() async {
    _errorMessage = null;

    if (!_termsAccepted) {
      _errorMessage = 'Lütfen şartları kabul ediniz.';
      notifyListeners();
      return false;
    }

    if (passwordController.text != passwordConfirmController.text) {
      _errorMessage = 'Şifreler eşleşmiyor.';
      notifyListeners();
      return false;
    }

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _errorMessage = 'Lütfen tüm zorunlu alanları doldurunuz.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(
        firstname: firstNameController.text.trim(),
        lastname: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        newsletter: _newsletter ? 1 : 0,
      );

      _isLoading = false;
      _lastStatusCode = result.statusCode;
      if (result.isSuccess) {
        if (result.data!.success) {
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Kayıt başarısız. Lütfen bilgilerinizi kontrol edin.';
        }
      } else {
        if (result.error?.contains('Email already exists') ?? false) {
          _errorMessage = 'Bu e-posta adresi zaten kullanımda.';
        } else {
          _errorMessage = result.error;
        }
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
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }
}
