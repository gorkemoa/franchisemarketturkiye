class HomeBanner {
  final int id;
  final String imageUrl;

  HomeBanner({required this.id, required this.imageUrl});

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: json['id'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}

class HomeBannerListResponse {
  final bool success;
  final HomeBannerListData data;
  final HomeBannerMeta meta;

  HomeBannerListResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory HomeBannerListResponse.fromJson(Map<String, dynamic> json) {
    return HomeBannerListResponse(
      success: json['success'] as bool? ?? false,
      data: HomeBannerListData.fromJson(json['data'] ?? {}),
      meta: HomeBannerMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class HomeBannerListData {
  final List<HomeBanner> items;
  final int count;

  HomeBannerListData({required this.items, required this.count});

  factory HomeBannerListData.fromJson(Map<String, dynamic> json) {
    return HomeBannerListData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => HomeBanner.fromJson(item))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }
}

class HomeBannerMeta {
  final String placement;

  HomeBannerMeta({required this.placement});

  factory HomeBannerMeta.fromJson(Map<String, dynamic> json) {
    return HomeBannerMeta(placement: json['placement'] as String? ?? '');
  }
}
