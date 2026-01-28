import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/app/app_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/franchise.dart';
import 'package:franchisemarketturkiye/models/franchise_category.dart';

class FranchiseService {
  final ApiClient _apiClient;

  FranchiseService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<ApiResult<FranchiseCategoryResponse>> getFranchiseCategories() async {
    final result = await _apiClient.get(ApiConstants.franchiseCategories);

    if (result.isSuccess && result.data != null) {
      try {
        final response = FranchiseCategoryResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }

  Future<ApiResult<FranchiseListResponse>> getFranchises({
    int limit = AppConstants.defaultLimit,
    int offset = 0,
    int? categoryId,
    String? q,
  }) async {
    String url = '${ApiConstants.franchises}?limit=$limit&offset=$offset';
    if (categoryId != null && categoryId != 0) {
      url += '&category_id=$categoryId';
    }
    if (q != null && q.isNotEmpty) {
      url += '&q=$q';
    }

    final result = await _apiClient.get(url);

    if (result.isSuccess && result.data != null) {
      try {
        final response = FranchiseListResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }

  Future<ApiResult<FranchiseDetailResponse>> getFranchiseDetail(int id) async {
    final result = await _apiClient.get('${ApiConstants.franchises}/$id');

    if (result.isSuccess && result.data != null) {
      try {
        final response = FranchiseDetailResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }
}
