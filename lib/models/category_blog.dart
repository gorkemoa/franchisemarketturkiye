import 'blog.dart';

class CategoryBlog {
  final int categoryId;
  final String categoryName;
  final String categoryLink;
  final List<Blog> blogs;
  final int count;

  CategoryBlog({
    required this.categoryId,
    required this.categoryName,
    required this.categoryLink,
    required this.blogs,
    required this.count,
  });

  factory CategoryBlog.fromJson(Map<String, dynamic> json) {
    final categoryId = json['category_id'] as int;
    final categoryName = json['category_name'] as String;
    final categoryLink = json['category_link'] as String;
    final category = BlogCategory(
      id: categoryId,
      name: categoryName,
      link: categoryLink,
    );

    return CategoryBlog(
      categoryId: categoryId,
      categoryName: categoryName,
      categoryLink: categoryLink,
      blogs: (json['blogs'] as List<dynamic>)
          .map(
            (blogJson) => Blog.fromJson(blogJson).copyWith(category: category),
          )
          .toList(),
      count: json['count'] as int,
    );
  }
}

class CategoryBlogResponse {
  final List<CategoryBlog> items;
  final int count;

  CategoryBlogResponse({required this.items, required this.count});

  factory CategoryBlogResponse.fromJson(Map<String, dynamic> json) {
    return CategoryBlogResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => CategoryBlog.fromJson(item))
          .toList(),
      count: json['count'] as int,
    );
  }
}
