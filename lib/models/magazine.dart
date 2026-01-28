class Magazine {
  final int id;
  final String title;
  final String description;
  final String link;
  final int price;
  final int viewed;
  final String image;
  final String imageUrl;
  final String path;
  final String fileUrl;
  final MagazineSeo seo;
  final int sortOrder;
  final DateTime dateAdded;

  Magazine({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    required this.price,
    required this.viewed,
    required this.image,
    required this.imageUrl,
    required this.path,
    required this.fileUrl,
    required this.seo,
    required this.sortOrder,
    required this.dateAdded,
  });

  factory Magazine.fromJson(Map<String, dynamic> json) {
    return Magazine(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      link: json['link'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      viewed: json['viewed'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      path: json['path'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      seo: MagazineSeo.fromJson(json['seo'] ?? {}),
      sortOrder: json['sort_order'] as int? ?? 0,
      dateAdded: json['date_added'] != null
          ? DateTime.parse(json['date_added'])
          : DateTime.now(),
    );
  }
}

class MagazineSeo {
  final String title;
  final String description;

  MagazineSeo({required this.title, required this.description});

  factory MagazineSeo.fromJson(Map<String, dynamic> json) {
    return MagazineSeo(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class MagazineListResponse {
  final bool success;
  final MagazineListData data;
  final MagazineMeta meta;

  MagazineListResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory MagazineListResponse.fromJson(Map<String, dynamic> json) {
    return MagazineListResponse(
      success: json['success'] as bool? ?? false,
      data: MagazineListData.fromJson(json['data'] ?? {}),
      meta: MagazineMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class MagazineListData {
  final List<Magazine> items;
  final int count;

  MagazineListData({required this.items, required this.count});

  factory MagazineListData.fromJson(Map<String, dynamic> json) {
    return MagazineListData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => Magazine.fromJson(item))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }
}

class MagazineMeta {
  final int limit;
  final bool hasMore;
  final String? nextCursor;

  MagazineMeta({required this.limit, required this.hasMore, this.nextCursor});

  factory MagazineMeta.fromJson(Map<String, dynamic> json) {
    return MagazineMeta(
      limit: json['limit'] as int? ?? 20,
      hasMore: json['has_more'] as bool? ?? false,
      nextCursor: json['next_cursor'] as String?,
    );
  }
}
