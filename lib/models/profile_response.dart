import 'package:franchisemarketturkiye/models/customer.dart';

class ProfileResponse {
  final bool success;
  final ProfileData? data;

  ProfileResponse({required this.success, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson()};
  }
}

class ProfileData {
  final Customer? customer;

  ProfileData({this.customer});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'customer': customer?.toJson()};
  }
}
