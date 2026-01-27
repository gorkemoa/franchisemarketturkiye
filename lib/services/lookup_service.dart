import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/lookup_models.dart';

class LookupService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<List<City>>> getCities() async {
    final result = await _apiClient.get(ApiConstants.cities);

    if (result.isSuccess) {
      try {
        final data = result.data!['data'];
        final items = data['items'] as List;
        final cities = items.map((e) => City.fromJson(e)).toList();
        return ApiResult.success(cities);
      } catch (e) {
        return ApiResult.failure('Parse Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Failed to load cities');
    }
  }

  Future<ApiResult<List<District>>> getDistricts(String cityId) async {
    final result = await _apiClient.get(ApiConstants.districts(cityId));

    if (result.isSuccess) {
      try {
        final data = result.data!['data'];
        final items = data['items'] as List;
        final districts = items.map((e) => District.fromJson(e)).toList();
        return ApiResult.success(districts);
      } catch (e) {
        return ApiResult.failure('Parse Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Failed to load districts');
    }
  }
}
