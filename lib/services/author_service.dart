import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/app/app_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/author.dart';

class AuthorService {
  final ApiClient _apiClient;

  AuthorService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResult<AuthorListResponse>> getAuthors({
    int limit = AppConstants.defaultLimit,
    String? cursor,
  }) async {
    String url = '${ApiConstants.authors}?limit=$limit';
    if (cursor != null) {
      url += '&cursor=$cursor';
    }

    final result = await _apiClient.get(url);

    if (result.isSuccess && result.data != null) {
      try {
        final response = AuthorListResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }

  Future<ApiResult<Author>> getAuthorDetail(int id) async {
    final result = await _apiClient.get(ApiConstants.authorDetail(id));

    if (result.isSuccess && result.data != null) {
      try {
        final data = result.data!['data'];
        if (data != null && data['item'] != null) {
          final author = Author.fromJson(data['item']);
          return ApiResult.success(author);
        } else {
          return ApiResult.failure('Author not found');
        }
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }

  Future<ApiResult<AuthorBlogsResponse>> getAuthorBlogs(
    int authorId, {
    int limit = AppConstants.defaultLimit,
    String? cursor,
    int excludePinned = 0,
  }) async {
    String url =
        '${ApiConstants.authorBlogs(authorId)}?limit=$limit&exclude_pinned=$excludePinned';
    if (cursor != null) {
      url += '&cursor=$cursor';
    }

    final result = await _apiClient.get(url);

    if (result.isSuccess && result.data != null) {
      try {
        final response = AuthorBlogsResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }
}
