import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/writer_application_service.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';
import 'package:franchisemarketturkiye/services/lookup_service.dart';
import 'package:file_picker/file_picker.dart';

class WriterApplicationViewModel extends ChangeNotifier {
  final WriterApplicationService _service = WriterApplicationService();
  final AuthService _authService = AuthService();
  final LookupService _lookupService = LookupService();

  WriterApplicationViewModel() {
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

  Future<void> _fetchProfile() async {
    final result = await _authService.getMe();
    if (result.isSuccess && result.data?.data?.customer != null) {
      final customer = result.data!.data!.customer!;
      firstNameController.text = customer.firstname ?? '';
      lastNameController.text = customer.lastname ?? '';
      emailController.text = customer.email ?? '';
      phoneController.text = customer.phone ?? '';

      String cityName = customer.city ?? '';
      String districtName = customer.district ?? '';

      // Resolve City and District IDs to names
      if (customer.city != null && customer.city!.isNotEmpty) {
        final citiesResult = await _lookupService.getCities();
        if (citiesResult.isSuccess) {
          // Match city by ID or Name
          final city = citiesResult.data!.where((c) {
            final cityIdMatch = c.id.toString() == customer.city;
            final cityNameMatch =
                c.name.toLowerCase() == customer.city!.toLowerCase();
            return cityIdMatch || cityNameMatch;
          }).firstOrNull;

          if (city != null) {
            cityName = city.name;
            if (customer.district != null && customer.district!.isNotEmpty) {
              final districtsResult = await _lookupService.getDistricts(
                city.id,
              );
              if (districtsResult.isSuccess) {
                // Match district by ID or Name
                final district = districtsResult.data!.where((d) {
                  final districtIdMatch = d.id.toString() == customer.district;
                  final districtNameMatch =
                      d.name.toLowerCase() == customer.district!.toLowerCase();
                  return districtIdMatch || districtNameMatch;
                }).firstOrNull;

                if (district != null) {
                  districtName = district.name;
                }
              }
            }
          }
        }
      }

      final List<String> addressParts = [];
      if (cityName.isNotEmpty) {
        addressParts.add('İl: $cityName');
      }
      if (districtName.isNotEmpty) {
        addressParts.add('İlçe: $districtName');
      }
      if (customer.neighbourhood != null &&
          customer.neighbourhood!.isNotEmpty) {
        addressParts.add('Mahalle: ${customer.neighbourhood}');
      }
      if (customer.street != null && customer.street!.isNotEmpty) {
        addressParts.add('Sokak/Cadde: ${customer.street}');
      }
      if (customer.address != null && customer.address!.isNotEmpty) {
        addressParts.add('Adres Detayı: ${customer.address}');
      }

      addressController.text = addressParts.join('\n');
      notifyListeners();
    }
  }

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
    _lastStatusCode = null;
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
        _lastStatusCode = result.statusCode;
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
        _lastStatusCode = result.statusCode;
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
