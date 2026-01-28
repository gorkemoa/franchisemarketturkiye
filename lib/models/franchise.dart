class Franchise {
  final int id;
  final int categoryId;
  final String title;
  final String link;
  final String tag;
  final String description;
  final String image;
  final String imageUrl;
  final String logo;
  final String logoUrl;
  final FranchiseSeo? seo;
  final int sortOrder;
  final String dateAdded;
  final String editDate;
  final List<FranchiseImage> images;
  final List<FranchiseOption> options;

  Franchise({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.link,
    required this.tag,
    required this.description,
    required this.image,
    required this.imageUrl,
    required this.logo,
    required this.logoUrl,
    this.seo,
    required this.sortOrder,
    required this.dateAdded,
    required this.editDate,
    this.images = const [],
    this.options = const [],
  });

  factory Franchise.fromJson(Map<String, dynamic> json) {
    return Franchise(
      id: json['id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      link: json['link'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      seo: json['seo'] != null ? FranchiseSeo.fromJson(json['seo']) : null,
      sortOrder: json['sort_order'] as int? ?? 0,
      dateAdded: json['date_added'] as String? ?? '',
      editDate: json['edit_date'] as String? ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => FranchiseImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => FranchiseOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'link': link,
      'tag': tag,
      'description': description,
      'image': image,
      'image_url': imageUrl,
      'logo': logo,
      'logo_url': logoUrl,
      'seo': seo?.toJson(),
      'sort_order': sortOrder,
      'date_added': dateAdded,
      'edit_date': editDate,
      'images': images.map((e) => e.toJson()).toList(),
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

class FranchiseImage {
  final int id;
  final String image;
  final String imageUrl;

  FranchiseImage({
    required this.id,
    required this.image,
    required this.imageUrl,
  });

  factory FranchiseImage.fromJson(Map<String, dynamic> json) {
    return FranchiseImage(
      id: json['id'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image': image, 'image_url': imageUrl};
  }
}

class FranchiseOption {
  final int id;
  final String title;
  final String icon;
  final String iconUrl;
  final int required;
  final String value;

  FranchiseOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconUrl,
    required this.required,
    required this.value,
  });

  factory FranchiseOption.fromJson(Map<String, dynamic> json) {
    return FranchiseOption(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      required: json['required'] as int? ?? 0,
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'icon_url': iconUrl,
      'required': required,
      'value': value,
    };
  }
}

class FranchiseSeo {
  final String title;
  final String description;

  FranchiseSeo({required this.title, required this.description});

  factory FranchiseSeo.fromJson(Map<String, dynamic> json) {
    return FranchiseSeo(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}

class FranchiseListResponse {
  final bool success;
  final FranchiseListData data;
  final FranchiseMeta meta;

  FranchiseListResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory FranchiseListResponse.fromJson(Map<String, dynamic> json) {
    return FranchiseListResponse(
      success: json['success'] as bool? ?? false,
      data: FranchiseListData.fromJson(json['data'] ?? {}),
      meta: FranchiseMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class FranchiseListData {
  final List<Franchise> items;
  final int count;
  final int total;

  FranchiseListData({
    required this.items,
    required this.count,
    required this.total,
  });

  factory FranchiseListData.fromJson(Map<String, dynamic> json) {
    return FranchiseListData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => Franchise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class FranchiseMeta {
  final int limit;
  final int offset;
  final int categoryId;
  final String q;

  FranchiseMeta({
    required this.limit,
    required this.offset,
    required this.categoryId,
    required this.q,
  });

  factory FranchiseMeta.fromJson(Map<String, dynamic> json) {
    return FranchiseMeta(
      limit: json['limit'] as int? ?? 0,
      offset: json['offset'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      q: json['q'] as String? ?? '',
    );
  }
}

class FranchiseDetailResponse {
  final bool success;
  final FranchiseDetailData data;

  FranchiseDetailResponse({required this.success, required this.data});

  factory FranchiseDetailResponse.fromJson(Map<String, dynamic> json) {
    return FranchiseDetailResponse(
      success: json['success'] as bool? ?? false,
      data: FranchiseDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class FranchiseDetailData {
  final Franchise item;

  FranchiseDetailData({required this.item});

  factory FranchiseDetailData.fromJson(Map<String, dynamic> json) {
    return FranchiseDetailData(item: Franchise.fromJson(json['item'] ?? {}));
  }
}
