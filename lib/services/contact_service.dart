import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';

class ContactService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<void>> sendMessage({
    required String fullname,
    required String phone,
    required String email,
    required String message,
  }) async {
    final body = {
      'fullname': fullname,
      'phone': phone,
      'email': email,
      'message': message,
    };

    final result = await _apiClient.post(ApiConstants.contact, body: body);

    if (result.isSuccess) {
      return ApiResult.success(null, statusCode: result.statusCode);
    } else {
      return ApiResult.failure(
        result.error ?? 'Mesaj gönderilemedi',
        statusCode: result.statusCode,
      );
    }
  }
}
