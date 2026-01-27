import 'package:franchisemarketturkiye/models/customer.dart';

class RegisterResponse {
  final bool success;
  final RegisterData? data;

  RegisterResponse({required this.success, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }
}

class RegisterData {
  final Customer? customer;

  RegisterData({this.customer});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
    );
  }
}
