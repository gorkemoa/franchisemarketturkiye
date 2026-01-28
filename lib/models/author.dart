import 'package:franchisemarketturkiye/models/blog.dart';

class Author {
  final int id;
  final String fullname;
  final String username;
  final String title;
  final String description;
  final String link;
  final String image;
  final String imageUrl;
  final AuthorSocial social;
  final AuthorSeo seo;
  final DateTime dateAdded;
  final int sortOrder;

  Author({
    required this.id,
    required this.fullname,
    required this.username,
    required this.title,
    required this.description,
    required this.link,
    required this.image,
    required this.imageUrl,
    required this.social,
    required this.seo,
    required this.dateAdded,
    required this.sortOrder,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as int,
      fullname: json['fullname'] as String,
      username: json['username'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      link: json['link'] as String,
      image: json['image'] as String,
      imageUrl: json['image_url'] as String,
      social: AuthorSocial.fromJson(json['social'] ?? {}),
      seo: AuthorSeo.fromJson(json['seo'] ?? {}),
      dateAdded: DateTime.parse(json['date_added']),
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

class AuthorSocial {
  final String facebook;
  final String instagram;
  final String youtube;
  final String twitter;

  AuthorSocial({
    required this.facebook,
    required this.instagram,
    required this.youtube,
    required this.twitter,
  });

  factory AuthorSocial.fromJson(Map<String, dynamic> json) {
    return AuthorSocial(
      facebook: json['facebook'] as String? ?? '',
      instagram: json['instagram'] as String? ?? '',
      youtube: json['youtube'] as String? ?? '',
      twitter: json['twitter'] as String? ?? '',
    );
  }
}

class AuthorSeo {
  final String title;
  final String description;

  AuthorSeo({required this.title, required this.description});

  factory AuthorSeo.fromJson(Map<String, dynamic> json) {
    return AuthorSeo(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class AuthorListResponse {
  final bool success;
  final AuthorListData data;
  final AuthorMeta meta;

  AuthorListResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory AuthorListResponse.fromJson(Map<String, dynamic> json) {
    return AuthorListResponse(
      success: json['success'] as bool,
      data: AuthorListData.fromJson(json['data']),
      meta: AuthorMeta.fromJson(json['meta']),
    );
  }
}

class AuthorListData {
  final List<Author> items;
  final int count;

  AuthorListData({required this.items, required this.count});

  factory AuthorListData.fromJson(Map<String, dynamic> json) {
    return AuthorListData(
      items: (json['items'] as List<dynamic>)
          .map((item) => Author.fromJson(item))
          .toList(),
      count: json['count'] as int,
    );
  }
}

class AuthorMeta {
  final int limit;
  final bool hasMore;
  final String? nextCursor;

  AuthorMeta({required this.limit, required this.hasMore, this.nextCursor});

  factory AuthorMeta.fromJson(Map<String, dynamic> json) {
    return AuthorMeta(
      limit: json['limit'] as int,
      hasMore: json['has_more'] as bool,
      nextCursor: json['next_cursor'] as String?,
    );
  }
}

class AuthorBlogsResponse {
  final bool success;
  final AuthorBlogsData data;
  final AuthorBlogsMeta meta;

  AuthorBlogsResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory AuthorBlogsResponse.fromJson(Map<String, dynamic> json) {
    return AuthorBlogsResponse(
      success: json['success'] as bool,
      data: AuthorBlogsData.fromJson(json['data']),
      meta: AuthorBlogsMeta.fromJson(json['meta']),
    );
  }
}

class AuthorBlogsData {
  final BlogAuthor author;
  final List<Blog> items;
  final int count;

  AuthorBlogsData({
    required this.author,
    required this.items,
    required this.count,
  });

  factory AuthorBlogsData.fromJson(Map<String, dynamic> json) {
    return AuthorBlogsData(
      author: BlogAuthor.fromJson(json['author']),
      items: (json['items'] as List<dynamic>)
          .map((item) => Blog.fromJson(item))
          .toList(),
      count: json['count'] as int,
    );
  }
}

class AuthorBlogsMeta {
  final int limit;
  final int excludePinned;
  final bool hasMore;
  final String? nextCursor;

  AuthorBlogsMeta({
    required this.limit,
    required this.excludePinned,
    required this.hasMore,
    this.nextCursor,
  });

  factory AuthorBlogsMeta.fromJson(Map<String, dynamic> json) {
    return AuthorBlogsMeta(
      limit: json['limit'] as int,
      excludePinned: json['exclude_pinned'] as int? ?? 0,
      hasMore: json['has_more'] as bool,
      nextCursor: json['next_cursor'] as String?,
    );
  }
}
