import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/magazine.dart';

class MagazineService {
  final ApiClient _apiClient;

  MagazineService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<ApiResult<MagazineListResponse>> getMagazines({
    int limit = 20,
    String? cursor,
  }) async {
    String url = '${ApiConstants.magazines}?limit=$limit';
    if (cursor != null) {
      url += '&cursor=$cursor';
    }

    final result = await _apiClient.get(url);

    if (result.isSuccess && result.data != null) {
      try {
        final response = MagazineListResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }

  Future<ApiResult<Magazine>> getMagazineDetail(int id) async {
    final result = await _apiClient.get(ApiConstants.magazineDetail(id));

    if (result.isSuccess && result.data != null) {
      try {
        final data = result.data!['data'];
        if (data != null && data['item'] != null) {
          final magazine = Magazine.fromJson(data['item']);
          return ApiResult.success(magazine);
        } else {
          return ApiResult.failure('Magazine not found');
        }
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }

  Future<ApiResult<List<int>>> downloadMagazine(
    String url, {
    required Function(double progress) onProgress,
  }) async {
    return await _apiClient.downloadFile(url, onProgress: onProgress);
  }
}
