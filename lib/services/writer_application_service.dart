import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriterApplicationService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<void>> createApplication({
    required String firstname,
    required String lastname,
    required String phone,
    required String email,
    required String socialMedia,
    required String address,
    required String message,
    String? cvPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // Fallback: If no token, maybe the API works public?
    // Usually application forms might be public.
    // However, if the API requires it, we send it.

    final fields = {
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'email': email,
      'social_media': socialMedia,
      'address': address,
      'message': message,
    };

    final files = cvPath != null ? {'cv': cvPath} : null;

    final result = await _apiClient.postMultipart(
      ApiConstants.writerApplications,
      fields: fields,
      files: files,
      token: token,
    );

    if (result.isSuccess) {
      return ApiResult.success(null);
    } else {
      return ApiResult.failure(result.error ?? 'Application failed');
    }
  }
}
