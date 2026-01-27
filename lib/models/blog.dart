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
      title: json['title'] as String,
      link: json['link'] as String,
      image: json['image'] as String,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
      seoTitle: json['seo_title'] as String,
      seoDescription: json['seo_description'] as String,
      tags: json['tags'] as String,
      dateAdded: DateTime.parse(json['date_added']),
      dateUpdate: DateTime.parse(json['date_update']),
      category: json['category'] != null
          ? BlogCategory.fromJson(json['category'])
          : null,
      type: BlogType.fromJson(json['type']),
      author: BlogAuthor.fromJson(json['author']),
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
  final String name;
  final String link;

  BlogCategory({required this.id, required this.name, required this.link});

  factory BlogCategory.fromJson(Map<String, dynamic> json) {
    return BlogCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      link: json['link'] as String,
    );
  }
}

class BlogType {
  final int id;
  final String name;
  final String link;

  BlogType({required this.id, required this.name, required this.link});

  factory BlogType.fromJson(Map<String, dynamic> json) {
    return BlogType(
      id: json['id'] as int,
      name: json['name'] as String,
      link: json['link'] as String,
    );
  }
}

class BlogAuthor {
  final int id;
  final String name;
  final String link;
  final String image;
  final String imageUrl;

  BlogAuthor({
    required this.id,
    required this.name,
    required this.link,
    required this.image,
    required this.imageUrl,
  });

  factory BlogAuthor.fromJson(Map<String, dynamic> json) {
    return BlogAuthor(
      id: json['id'] as int,
      name: json['name'] as String,
      link: json['link'] as String,
      image: json['image'] as String,
      imageUrl: json['image_url'] as String,
    );
  }
}

class BlogResponse {
  final List<Blog> items;
  final int count;

  BlogResponse({required this.items, required this.count});

  factory BlogResponse.fromJson(Map<String, dynamic> json) {
    return BlogResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => Blog.fromJson(item))
          .toList(),
      count: json['count'] as int,
    );
  }
}
