import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/banner.dart';

class BannerService {
  final ApiClient _apiClient;

  BannerService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResult<HomeBannerListResponse>> getBanners() async {
    final result = await _apiClient.get(ApiConstants.banners);

    if (result.isSuccess && result.data != null) {
      try {
        final response = HomeBannerListResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }
}
