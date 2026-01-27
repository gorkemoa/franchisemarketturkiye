class Category {
  final int id;
  final String name;
  final String link;
  final String? description;
  final String? image;
  final String? imageUrl;
  final CategorySeo? seo;
  final int? sortOrder;
  final int? selected;
  final int? count;

  Category({
    required this.id,
    required this.name,
    required this.link,
    this.description,
    this.image,
    this.imageUrl,
    this.seo,
    this.sortOrder,
    this.selected,
    this.count,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      link: json['link'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,
      seo: json['seo'] != null ? CategorySeo.fromJson(json['seo']) : null,
      sortOrder: json['sort_order'] as int?,
      selected: json['selected'] as int?,
      count: json['count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'link': link,
      'description': description,
      'image': image,
      'image_url': imageUrl,
      'seo': seo?.toJson(),
      'sort_order': sortOrder,
      'selected': selected,
      'count': count,
    };
  }
}

class CategorySeo {
  final String? title;
  final String? description;

  CategorySeo({this.title, this.description});

  factory CategorySeo.fromJson(Map<String, dynamic> json) {
    return CategorySeo(
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}

class CategoryResponse {
  final List<Category> items;
  final int count;

  CategoryResponse({required this.items, required this.count});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => Category.fromJson(item))
          .toList(),
      count: json['count'] as int,
    );
  }
}

class CategoryDetailResponse {
  final Category item;

  CategoryDetailResponse({required this.item});

  factory CategoryDetailResponse.fromJson(Map<String, dynamic> json) {
    return CategoryDetailResponse(item: Category.fromJson(json['item']));
  }
}
