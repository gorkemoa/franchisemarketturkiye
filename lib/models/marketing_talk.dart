class MarketingTalkResponse {
  final List<MarketingTalk> items;
  final int count;

  MarketingTalkResponse({required this.items, required this.count});

  factory MarketingTalkResponse.fromJson(Map<String, dynamic> json) {
    return MarketingTalkResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => MarketingTalk.fromJson(item))
          .toList(),
      count: json['count'] as int,
    );
  }
}

class MarketingTalk {
  final int id;
  final String title;
  final String link;
  final String image;
  final String imageUrl;
  final int sortOrder;

  MarketingTalk({
    required this.id,
    required this.title,
    required this.link,
    required this.image,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory MarketingTalk.fromJson(Map<String, dynamic> json) {
    return MarketingTalk(
      id: json['id'] as int,
      title: json['title'] as String,
      link: json['link'] as String,
      image: json['image'] as String,
      imageUrl: json['image_url'] as String,
      sortOrder: json['sort_order'] as int,
    );
  }
}

class MarketingTalkMeta {
  final int limit;

  MarketingTalkMeta({required this.limit});

  factory MarketingTalkMeta.fromJson(Map<String, dynamic> json) {
    return MarketingTalkMeta(limit: json['limit'] as int);
  }
}
