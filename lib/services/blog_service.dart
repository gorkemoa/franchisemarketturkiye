import 'package:franchisemarketturkiye/app/api_constants.dart';
import 'package:franchisemarketturkiye/app/app_constants.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/models/blog.dart';

import 'package:franchisemarketturkiye/models/category_blog.dart';
import 'package:franchisemarketturkiye/models/marketing_talk.dart';

class BlogService {
  final ApiClient _apiClient;

  BlogService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResult<List<Blog>>> getFeaturedBlogs({int limit = 4}) async {
    final result = await _apiClient.get(
      '${ApiConstants.featuredBlogs}?limit=$limit',
    );

    if (result.isSuccess && result.data != null) {
      try {
        final data = result.data!['data'];
        if (data != null && data['items'] != null) {
          final List<dynamic> items = data['items'];
          final blogs = items.map((item) => Blog.fromJson(item)).toList();
          return ApiResult.success(blogs);
        } else {
          // Handle case where data structure is unexpected but request succeeded (e.g. empty list)
          return ApiResult.success([]);
        }
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }

  Future<ApiResult<List<Blog>>> getSliderBlogs({int limit = 10}) async {
    final result = await _apiClient.get(
      '${ApiConstants.sliderBlogs}?limit=$limit',
    );

    if (result.isSuccess && result.data != null) {
      try {
        final data = result.data!['data'];
        if (data != null && data['items'] != null) {
          final List<dynamic> items = data['items'];
          final blogs = items.map((item) => Blog.fromJson(item)).toList();
          return ApiResult.success(blogs);
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

  Future<ApiResult<List<CategoryBlog>>> getSelectedCategoryBlogs() async {
    final result = await _apiClient.get(ApiConstants.selectedCategoryBlogs);

    if (result.isSuccess && result.data != null) {
      try {
        final data = result.data!['data'];
        if (data != null) {
          final response = CategoryBlogResponse.fromJson(data);
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

  Future<ApiResult<List<MarketingTalk>>> getMarketingTalks({
    int limit = 20,
  }) async {
    final result = await _apiClient.get(
      '${ApiConstants.marketingTalks}?limit=$limit',
    );

    if (result.isSuccess && result.data != null) {
      try {
        final data = result.data!['data'];
        if (data != null) {
          final response = MarketingTalkResponse.fromJson(data);
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

  Future<ApiResult<Blog>> getBlogById(int id) async {
    final result = await _apiClient.get(ApiConstants.blogDetail(id));

    if (result.isSuccess && result.data != null) {
      try {
        final data = result.data!['data'];
        if (data != null && data['item'] != null) {
          final blog = Blog.fromJson(data['item']);
          return ApiResult.success(blog);
        } else {
          return ApiResult.failure('Blog not found');
        }
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }

  Future<ApiResult<CategoryBlogsResponse>> getBlogsByCategory(
    int categoryId, {
    int limit = AppConstants.defaultLimit,
    String? cursor,
    int excludePinned = 0,
  }) async {
    String url =
        '${ApiConstants.categoryBlogs(categoryId)}?limit=$limit&exclude_pinned=$excludePinned';
    if (cursor != null) {
      url += '&cursor=$cursor';
    }

    final result = await _apiClient.get(url);

    if (result.isSuccess && result.data != null) {
      try {
        final response = CategoryBlogsResponse.fromJson(result.data!);
        return ApiResult.success(response);
      } catch (e) {
        return ApiResult.failure('Parsing Error: $e');
      }
    } else {
      return ApiResult.failure(result.error ?? 'Unknown Error');
    }
  }
}
