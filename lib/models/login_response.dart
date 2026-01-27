import 'package:franchisemarketturkiye/models/customer.dart';

class LoginResponse {
  final bool success;
  final LoginData? data;

  LoginResponse({required this.success, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson()};
  }
}

class LoginData {
  final String? accessToken;
  final String? tokenType;
  final String? expiresAt;
  final Customer? customer;

  LoginData({this.accessToken, this.tokenType, this.expiresAt, this.customer});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresAt: json['expires_at'],
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_at': expiresAt,
      'customer': customer?.toJson(),
    };
  }
}
