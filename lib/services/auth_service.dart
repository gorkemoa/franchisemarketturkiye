import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  static const String _tokenKey = 'access_token';

  Future<ApiResult<LoginResponse>> login(String email, String password) async {
    final result = await _apiClient.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    if (result.isSuccess) {
      final loginResponse = LoginResponse.fromJson(result.data!);
      if (loginResponse.success && loginResponse.data?.accessToken != null) {
        await _saveToken(loginResponse.data!.accessToken!);
      }
      return ApiResult.success(loginResponse);
    } else {
      return ApiResult.failure(result.error ?? 'Login failed');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
