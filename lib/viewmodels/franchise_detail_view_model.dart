import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/franchise.dart';
import 'package:franchisemarketturkiye/models/lookup_models.dart';
import 'package:franchisemarketturkiye/models/profile_response.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';
import 'package:franchisemarketturkiye/services/franchise_service.dart';
import 'package:franchisemarketturkiye/services/lookup_service.dart';

class FranchiseDetailViewModel extends ChangeNotifier {
  final FranchiseService _franchiseService = FranchiseService();
  final LookupService _lookupService = LookupService();
  final AuthService _authService = AuthService();
  final int franchiseId;

  Franchise? _franchise;
  bool _isLoading = false;
  bool _isApplying = false;
  String? _errorMessage;
  int? _lastStatusCode;

  List<City> _cities = [];
  List<District> _districts = [];

  Franchise? get franchise => _franchise;
  bool get isLoading => _isLoading;
  bool get isApplying => _isApplying;
  String? get errorMessage => _errorMessage;
  List<City> get cities => _cities;
  List<District> get districts => _districts;
  int? get lastStatusCode => _lastStatusCode;

  FranchiseDetailViewModel({required this.franchiseId});

  Future<void> fetchFranchiseDetail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _franchiseService.getFranchiseDetail(franchiseId);
    _lastStatusCode = result.statusCode;

    if (result.isSuccess && result.data != null) {
      _franchise = result.data!.data.item;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCities() async {
    final result = await _lookupService.getCities();
    if (result.isSuccess && result.data != null) {
      _cities = result.data!;
      notifyListeners();
    }
  }

  Future<void> fetchDistricts(String cityId) async {
    final result = await _lookupService.getDistricts(cityId);
    if (result.isSuccess && result.data != null) {
      _districts = result.data!;
      notifyListeners();
    }
  }

  Future<ProfileResponse?> getCurrentUser() async {
    final result = await _authService.getMe();
    if (result.isSuccess) {
      return result.data;
    }
    return null;
  }

  Future<bool> applyToFranchise({
    required String firstname,
    required String lastname,
    required String phone,
    required String email,
    required int city,
    required int district,
    required String description,
  }) async {
    _isApplying = true;
    notifyListeners();

    final result = await _franchiseService.applyToFranchise(
      franchiseId: franchiseId,
      firstname: firstname,
      lastname: lastname,
      phone: phone,
      email: email,
      city: city,
      district: district,
      description: description,
    );

    _lastStatusCode = result.statusCode;
    if (!result.isSuccess) {
      _errorMessage = result.error;
    }

    _isApplying = false;
    notifyListeners();

    return result.isSuccess;
  }
}
