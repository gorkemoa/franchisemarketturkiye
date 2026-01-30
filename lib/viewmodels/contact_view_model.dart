import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/contact_service.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';

class ContactViewModel extends ChangeNotifier {
  final ContactService _service = ContactService();
  final AuthService _authService = AuthService();

  ContactViewModel() {
    _fetchProfile();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  int? _lastStatusCode;
  int? get lastStatusCode => _lastStatusCode;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  Future<void> _fetchProfile() async {
    final result = await _authService.getMe();
    if (result.isSuccess && result.data?.data?.customer != null) {
      final customer = result.data!.data!.customer!;
      final firstName = customer.firstname ?? '';
      final lastName = customer.lastname ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        fullNameController.text = '$firstName $lastName'.trim();
      }
      emailController.text = customer.email ?? '';
      phoneController.text = customer.phone ?? '';
      notifyListeners();
    }
  }

  Future<void> sendMessage() async {
    if (fullNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        messageController.text.isEmpty) {
      _errorMessage = 'Lütfen tüm alanları doldurunuz.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    final result = await _service.sendMessage(
      fullname: fullNameController.text,
      phone: phoneController.text,
      email: emailController.text,
      message: messageController.text,
    );

    _lastStatusCode = result.statusCode;
    if (result.isSuccess) {
      _successMessage = 'Mesajınız başarıyla gönderildi.';
      fullNameController.clear();
      phoneController.clear();
      emailController.clear();
      messageController.clear();
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
