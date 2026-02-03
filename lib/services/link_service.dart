import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/link_resolve_response.dart';

class LinkService {
  static final LinkService _instance = LinkService._internal();
  factory LinkService() => _instance;
  LinkService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Resolves a link to get its native type and ID
  /// type can be 'blog', 'magazine', or 'franchise'
  Future<ApiResult<LinkResolveResponse>> resolveLink({
    required String link,
    required String type,
  }) async {
    const String url = ApiConstants.resolveLink;
    final String queryUrl = '$url?link=$link&type=$type';

    final result = await _apiClient.get(queryUrl);

    if (result.isSuccess && result.data != null) {
      try {
        final response = LinkResolveResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } catch (e) {
        return ApiResult.failure('Parse Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown error');
    }
  }
}
