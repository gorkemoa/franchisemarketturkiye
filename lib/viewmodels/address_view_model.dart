import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';
import 'package:franchisemarketturkiye/services/lookup_service.dart';
import 'package:franchisemarketturkiye/models/lookup_models.dart';

class AddressViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LookupService _lookupService = LookupService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<City> _cities = [];
  List<City> get cities => _cities;

  List<District> _districts = [];
  List<District> get districts => _districts;

  City? _selectedCity;
  City? get selectedCity => _selectedCity;

  District? _selectedDistrict;
  District? get selectedDistrict => _selectedDistrict;

  final TextEditingController neighbourhoodController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController addressDetailController = TextEditingController();

  AddressViewModel() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    // Fetch Cities
    final citiesResult = await _lookupService.getCities();
    if (citiesResult.isSuccess) {
      _cities = citiesResult.data!;
    } else {
      _errorMessage = 'Şehirler yüklenirken hata oluştu.';
    }

    // Try to load current user data to pre-fill
    // Assuming we might have some data in cache or fetch profile again
    // For now we rely on user profile fetch if needed, but this VM is isolated.
    // Let's assume we start empty or could take arguments.
    // If we want to pre-fill, we need the current profile.
    final profileResult = await _authService.getMe();
    if (profileResult.isSuccess && profileResult.data?.data?.customer != null) {
      final customer = profileResult.data!.data!.customer!;
      neighbourhoodController.text = customer.neighbourhood ?? '';
      streetController.text = customer.street ?? '';
      addressDetailController.text = customer.address ?? '';

      // Match city by ID
      if (customer.city != null && _cities.isNotEmpty) {
        try {
          // Try exact ID match first
          _selectedCity = _cities.firstWhere(
            (c) => c.id == customer.city,
            orElse: () => _cities.firstWhere(
              (c) => c.name.toUpperCase() == customer.city!.toUpperCase(),
            ),
          );

          if (_selectedCity != null) {
            await _loadDistricts(_selectedCity!);
            if (customer.district != null) {
              try {
                // Try exact ID match first for district
                _selectedDistrict = _districts.firstWhere(
                  (d) => d.id == customer.district,
                  orElse: () => _districts.firstWhere(
                    (d) =>
                        d.name.toUpperCase() ==
                        customer.district!.toUpperCase(),
                  ),
                );
              } catch (_) {}
            }
          }
        } catch (_) {}
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> onCityChanged(City? city) async {
    _selectedCity = city;
    _selectedDistrict = null;
    _districts = [];
    notifyListeners();

    if (city != null) {
      await _loadDistricts(city);
    }
  }

  Future<void> _loadDistricts(City city) async {
    _isLoading = true;
    notifyListeners();

    final result = await _lookupService.getDistricts(city.id);
    if (result.isSuccess) {
      _districts = result.data!;
    } else {
      _errorMessage = 'İlçeler yüklenemedi';
    }

    _isLoading = false;
    notifyListeners();
  }

  void onDistrictChanged(District? district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  Future<bool> saveAddress() async {
    if (_selectedCity == null || _selectedDistrict == null) {
      _errorMessage = 'Lütfen şehir ve ilçe seçiniz.';
      notifyListeners();
      return false;
    }

    if (neighbourhoodController.text.isEmpty ||
        streetController.text.isEmpty ||
        addressDetailController.text.isEmpty) {
      _errorMessage = 'Lütfen tüm adres detaylarını doldurunuz.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updateAddress(
      cityId: _selectedCity!.id,
      districtId: _selectedDistrict!.id,
      neighbourhood: neighbourhoodController.text.trim(),
      street: streetController.text.trim(),
      address: addressDetailController.text.trim(),
    );

    _isLoading = false;
    notifyListeners();

    if (result.isSuccess) {
      return true;
    } else {
      _errorMessage = result.error;
      return false;
    }
  }
}
