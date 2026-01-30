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
        return ApiResult.success(response, statusCode: result.statusCode);
      } catch (e) {
        return ApiResult.failure(
          'Parsing Error: $e',
          statusCode: result.statusCode,
        );
      }
    } else {
      return ApiResult.failure(
        result.error ?? 'Unknown Error',
        statusCode: result.statusCode,
      );
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
        return ApiResult.success(response, statusCode: result.statusCode);
      } catch (e) {
        return ApiResult.failure(
          'Parsing Error: $e',
          statusCode: result.statusCode,
        );
      }
    } else {
      return ApiResult.failure(
        result.error ?? 'Unknown Error',
        statusCode: result.statusCode,
      );
    }
  }

  Future<ApiResult<FranchiseDetailResponse>> getFranchiseDetail(int id) async {
    final result = await _apiClient.get('${ApiConstants.franchises}/$id');

    if (result.isSuccess && result.data != null) {
      try {
        final response = FranchiseDetailResponse.fromJson(result.data!);
        return ApiResult.success(response, statusCode: result.statusCode);
      } catch (e) {
        return ApiResult.failure(
          'Parsing Error: $e',
          statusCode: result.statusCode,
        );
      }
    } else {
      return ApiResult.failure(
        result.error ?? 'Unknown Error',
        statusCode: result.statusCode,
      );
    }
  }

  Future<ApiResult<bool>> applyToFranchise({
    required int franchiseId,
    required String firstname,
    required String lastname,
    required String phone,
    required String email,
    required int city,
    required int district,
    required String description,
  }) async {
    final body = {
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'email': email,
      'city': city,
      'district': district,
      'description': description,
    };

    final result = await _apiClient.post(
      ApiConstants.franchiseApply(franchiseId),
      body: body,
    );

    if (result.isSuccess) {
      return ApiResult.success(true, statusCode: result.statusCode);
    } else {
      return ApiResult.failure(
        result.error ?? 'Başvuru sırasında bir hata oluştu.',
        statusCode: result.statusCode,
      );
    }
  }
}
