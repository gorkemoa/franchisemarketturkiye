class Blog {
  final int id;
  final String title;
  final String link;
  final String image;
  final String imageUrl;
  final String description;
  final String seoTitle;
  final String seoDescription;
  final String tags;
  final DateTime dateAdded;
  final DateTime dateUpdate;
  final BlogCategory? category;
  final BlogType type;
  final BlogAuthor author;

  Blog({
    required this.id,
    required this.title,
    required this.link,
    required this.image,
    required this.imageUrl,
    required this.description,
    required this.seoTitle,
    required this.seoDescription,
    required this.tags,
    required this.dateAdded,
    required this.dateUpdate,
    this.category,
    required this.type,
    required this.author,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      link: json['link'] as String? ?? '',
      image: json['image'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      seoTitle: json['seo_title'] as String? ?? '',
      seoDescription: json['seo_description'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      dateAdded: json['date_added'] != null
          ? DateTime.parse(json['date_added'])
          : DateTime.now(),
      dateUpdate: json['date_update'] != null
          ? DateTime.parse(json['date_update'])
          : DateTime.now(),
      category: json['category'] != null
          ? BlogCategory.fromJson(json['category'])
          : null,
      type: BlogType.fromJson(json['type'] ?? {}),
      author: BlogAuthor.fromJson(json['author'] ?? {}),
    );
  }

  Blog copyWith({
    int? id,
    String? title,
    String? link,
    String? image,
    String? imageUrl,
    String? description,
    String? seoTitle,
    String? seoDescription,
    String? tags,
    DateTime? dateAdded,
    DateTime? dateUpdate,
    BlogCategory? category,
    BlogType? type,
    BlogAuthor? author,
  }) {
    return Blog(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      seoTitle: seoTitle ?? this.seoTitle,
      seoDescription: seoDescription ?? this.seoDescription,
      tags: tags ?? this.tags,
      dateAdded: dateAdded ?? this.dateAdded,
      dateUpdate: dateUpdate ?? this.dateUpdate,
      category: category ?? this.category,
      type: type ?? this.type,
      author: author ?? this.author,
    );
  }
}

class BlogCategory {
  final int id;
  final String? name;
  final String? link;

  BlogCategory({required this.id, this.name, this.link});

  factory BlogCategory.fromJson(Map<String, dynamic> json) {
    return BlogCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      link: json['link'] as String?,
    );
  }
}

class BlogType {
  final int id;
  final String? name;
  final String? link;

  BlogType({required this.id, this.name, this.link});

  factory BlogType.fromJson(Map<String, dynamic> json) {
    return BlogType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      link: json['link'] as String?,
    );
  }
}

class BlogAuthor {
  final int id;
  final String? name;
  final String? link;
  final String? image;
  final String? imageUrl;

  BlogAuthor({
    required this.id,
    this.name,
    this.link,
    this.image,
    this.imageUrl,
  });

  factory BlogAuthor.fromJson(Map<String, dynamic> json) {
    return BlogAuthor(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      link: json['link'] as String?,
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class BlogResponse {
  final List<Blog> items;
  final int count;

  BlogResponse({required this.items, required this.count});

  factory BlogResponse.fromJson(Map<String, dynamic> json) {
    return BlogResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => Blog.fromJson(item))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }
}

class CategoryBlogsResponse {
  final bool success;
  final CategoryBlogsData data;
  final BlogMeta meta;

  CategoryBlogsResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory CategoryBlogsResponse.fromJson(Map<String, dynamic> json) {
    return CategoryBlogsResponse(
      success: json['success'] as bool? ?? false,
      data: CategoryBlogsData.fromJson(json['data'] ?? {}),
      meta: BlogMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class CategoryBlogsData {
  final BlogCategory category;
  final List<Blog> items;
  final int count;

  CategoryBlogsData({
    required this.category,
    required this.items,
    required this.count,
  });

  factory CategoryBlogsData.fromJson(Map<String, dynamic> json) {
    return CategoryBlogsData(
      category: BlogCategory.fromJson(json['category'] ?? {}),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => Blog.fromJson(item))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }
}

class BlogMeta {
  final int limit;
  final int excludePinned;
  final bool hasMore;
  final int totalItems;
  final String? nextCursor;

  BlogMeta({
    required this.limit,
    required this.excludePinned,
    required this.hasMore,
    required this.totalItems,
    this.nextCursor,
  });

  factory BlogMeta.fromJson(Map<String, dynamic> json) {
    return BlogMeta(
      limit: json['limit'] as int? ?? 10,
      excludePinned: json['exclude_pinned'] as int? ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
      totalItems: json['total_items'] as int? ?? 0,
      nextCursor: json['next_cursor'] as String?,
    );
  }
}

class BlogSearchResponse {
  final bool success;
  final BlogSearchData data;
  final BlogSearchMeta meta;

  BlogSearchResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory BlogSearchResponse.fromJson(Map<String, dynamic> json) {
    return BlogSearchResponse(
      success: json['success'] as bool? ?? false,
      data: BlogSearchData.fromJson(json['data'] ?? {}),
      meta: BlogSearchMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class BlogSearchData {
  final List<Blog> items;
  final int count;
  final int total;
  final bool hasMore;

  BlogSearchData({
    required this.items,
    required this.count,
    required this.total,
    required this.hasMore,
  });

  factory BlogSearchData.fromJson(Map<String, dynamic> json) {
    return BlogSearchData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => Blog.fromJson(item))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}

class BlogSearchMeta {
  final String q;
  final int limit;
  final int offset;

  BlogSearchMeta({required this.q, required this.limit, required this.offset});

  factory BlogSearchMeta.fromJson(Map<String, dynamic> json) {
    return BlogSearchMeta(
      q: json['q'] as String? ?? '',
      limit: json['limit'] as int? ?? 10,
      offset: json['offset'] as int? ?? 0,
    );
  }
}
