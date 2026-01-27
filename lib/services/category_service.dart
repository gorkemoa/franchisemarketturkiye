import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/category.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<ApiResult<List<Category>>> getCategories({int selected = 0}) async {
    final result = await _apiClient.get(
      '${ApiConstants.categories}?selected=$selected',
    );

    if (result.isSuccess && result.data != null) {
      try {
        final data = result.data!['data'];
        if (data != null) {
          final response = CategoryResponse.fromJson(data);
          return ApiResult.success(response.items);
        } else {
          return ApiResult.success([]);
        }
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }

  Future<ApiResult<Category>> getCategoryById(int categoryId) async {
    final result = await _apiClient.get(
      ApiConstants.categoryDetail(categoryId),
    );

    if (result.isSuccess && result.data != null) {
      try {
        final data = result.data!['data'];
        if (data != null) {
          final response = CategoryDetailResponse.fromJson(data);
          return ApiResult.success(response.item);
        } else {
          return ApiResult.failure('Category not found');
        }
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }
}
