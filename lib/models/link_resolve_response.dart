class LinkResolveResponse {
  final bool success;
  final LinkResolveData? data;
  final LinkResolveMeta? meta;

  LinkResolveResponse({required this.success, this.data, this.meta});

  factory LinkResolveResponse.fromJson(Map<String, dynamic> json) {
    return LinkResolveResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null
          ? LinkResolveData.fromJson(json['data'])
          : null,
      meta: json['meta'] != null
          ? LinkResolveMeta.fromJson(json['meta'])
          : null,
    );
  }
}

class LinkResolveData {
  final String type;
  final LinkResolveItem item;

  LinkResolveData({required this.type, required this.item});

  factory LinkResolveData.fromJson(Map<String, dynamic> json) {
    return LinkResolveData(
      type: json['type'] as String? ?? '',
      item: LinkResolveItem.fromJson(json['item'] ?? {}),
    );
  }
}

class LinkResolveItem {
  final int id;
  final String title;
  final String link;
  final String? image;
  final String? imageUrl;
  final String? description;
  final String? seoTitle;
  final String? seoDescription;
  final String? tags;
  final String? dateAdded;
  final String? dateUpdate;

  LinkResolveItem({
    required this.id,
    required this.title,
    required this.link,
    this.image,
    this.imageUrl,
    this.description,
    this.seoTitle,
    this.seoDescription,
    this.tags,
    this.dateAdded,
    this.dateUpdate,
  });

  factory LinkResolveItem.fromJson(Map<String, dynamic> json) {
    return LinkResolveItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      link: json['link'] as String? ?? '',
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      seoTitle: json['seo_title'] as String?,
      seoDescription: json['seo_description'] as String?,
      tags: json['tags'] as String?,
      dateAdded: json['date_added'] as String?,
      dateUpdate: json['date_update'] as String?,
    );
  }
}

class LinkResolveMeta {
  final String link;

  LinkResolveMeta({required this.link});

  factory LinkResolveMeta.fromJson(Map<String, dynamic> json) {
    return LinkResolveMeta(link: json['link'] as String? ?? '');
  }
}
