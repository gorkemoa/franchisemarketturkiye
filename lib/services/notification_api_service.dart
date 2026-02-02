import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/notification.dart';

class NotificationApiService {
  final ApiClient _apiClient;

  NotificationApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<ApiResult<List<AppNotification>>> getNotifications({
    int limit = 20,
  }) async {
    final result = await _apiClient.get(
      '${ApiConstants.notifications}?limit=$limit',
    );

    if (result.isSuccess && result.data != null) {
      try {
        final response = NotificationResponse.fromJson(result.data!);
        if (response.success) {
          return ApiResult.success(response.data.items);
        } else {
          return ApiResult.failure('API returned success: false');
        }
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }
}
