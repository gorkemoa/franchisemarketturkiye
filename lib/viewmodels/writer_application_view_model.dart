import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/writer_application_service.dart';
import 'package:file_picker/file_picker.dart';

class WriterApplicationViewModel extends ChangeNotifier {
  final WriterApplicationService _service = WriterApplicationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _cvPath;
  String? get cvPath => _cvPath;
  String? get cvName => _cvPath?.split('/').last;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController socialMediaController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  Future<void> pickCv() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        _cvPath = result.files.single.path;
        _errorMessage = null; // Clear error if any
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Dosya seçimi sırasında hata oluştu: $e';
      notifyListeners();
    }
  }

  void removeCv() {
    _cvPath = null;
    notifyListeners();
  }

  Future<bool> submitApplication() async {
    // Validate
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty) {
      _errorMessage = 'Lütfen zorunlu alanları (*) doldurunuz.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _service.createApplication(
        firstname: firstNameController.text,
        lastname: lastNameController.text,
        phone: phoneController.text,
        email: emailController.text,
        socialMedia: socialMediaController.text,
        address: addressController.text,
        message: messageController.text,
        cvPath: _cvPath,
      );

      if (result.isSuccess) {
        _successMessage = "Başvurunuz başarıyla alındı.";
        firstNameController.clear();
        lastNameController.clear();
        phoneController.clear();
        emailController.clear();
        socialMediaController.clear();
        addressController.clear();
        messageController.clear();
        _cvPath = null;
      } else {
        _errorMessage = result.error;
      }
    } catch (e) {
      _errorMessage = "Hata oluştu: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _successMessage != null;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    socialMediaController.dispose();
    addressController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
