class AppNotification {
  final int id;
  final String topic;
  final String title;
  final String body;
  final String? linkUrl;
  final String? imageUrl;
  final String? targetType;
  final int? itemId;
  final DateTime updatedAt;

  AppNotification({
    required this.id,
    required this.topic,
    required this.title,
    required this.body,
    this.linkUrl,
    this.imageUrl,
    this.targetType,
    this.itemId,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      topic: json['topic'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      linkUrl: json['link_url'] as String?,
      imageUrl: json['image_url'] as String?,
      targetType: json['target_type'] as String?,
      itemId: int.tryParse(json['item_id']?.toString() ?? ''),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}

class NotificationResponse {
  final bool success;
  final NotificationData data;
  final NotificationMeta meta;

  NotificationResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] as bool? ?? false,
      data: NotificationData.fromJson(json['data'] ?? {}),
      meta: NotificationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class NotificationData {
  final List<AppNotification> items;
  final int count;

  NotificationData({required this.items, required this.count});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => AppNotification.fromJson(item))
              .toList() ??
          [],
      count: int.tryParse(json['count']?.toString() ?? '') ?? 0,
    );
  }
}

class NotificationMeta {
  final int limit;

  NotificationMeta({required this.limit});

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      limit: int.tryParse(json['limit']?.toString() ?? '') ?? 20,
    );
  }
}
