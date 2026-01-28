import 'package:franchisemarketturkiye/models/franchise.dart';

class FranchiseCategoryResponse {
  final bool success;
  final FranchiseCategoryListData data;
  final FranchiseCategoryMeta? meta;

  FranchiseCategoryResponse({
    required this.success,
    required this.data,
    this.meta,
  });

  factory FranchiseCategoryResponse.fromJson(Map<String, dynamic> json) {
    return FranchiseCategoryResponse(
      success: json['success'] ?? false,
      data: FranchiseCategoryListData.fromJson(json['data'] ?? {}),
      meta: json['meta'] != null
          ? FranchiseCategoryMeta.fromJson(json['meta'])
          : null,
    );
  }
}

class FranchiseCategoryListData {
  final List<FranchiseCategory> items;
  final int count;

  FranchiseCategoryListData({required this.items, required this.count});

  factory FranchiseCategoryListData.fromJson(Map<String, dynamic> json) {
    return FranchiseCategoryListData(
      items:
          (json['items'] as List?)
              ?.map((e) => FranchiseCategory.fromJson(e))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }
}

class FranchiseCategory {
  final int id;
  final String title;
  final String link;
  final FranchiseSeo? seo;
  final int parentId;
  final int sortOrder;

  FranchiseCategory({
    required this.id,
    required this.title,
    required this.link,
    this.seo,
    required this.parentId,
    required this.sortOrder,
  });

  factory FranchiseCategory.fromJson(Map<String, dynamic> json) {
    return FranchiseCategory(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      seo: json['seo'] != null ? FranchiseSeo.fromJson(json['seo']) : null,
      parentId: json['parent_id'] ?? 0,
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}

class FranchiseCategoryMeta {
  final int? parentId;

  FranchiseCategoryMeta({this.parentId});

  factory FranchiseCategoryMeta.fromJson(Map<String, dynamic> json) {
    return FranchiseCategoryMeta(parentId: json['parent_id']);
  }
}
