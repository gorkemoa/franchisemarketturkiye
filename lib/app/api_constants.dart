class ApiConstants {
  static const String baseUrl = 'https://franchisemarketturkiye.com';
  static const String apiKey = 'FMTRK_PROD_1234567890abcdef1234567890abcdef';
  static const String featuredBlogs = '$baseUrl/api/v1/blogs/featured';
  static const String sliderBlogs = '$baseUrl/api/v1/blogs/sliders';
  static const String selectedCategoryBlogs =
      '$baseUrl/api/v1/blogs/selected-categories';
  static const String marketingTalks = '$baseUrl/api/v1/marketing-talks';
  static String blogDetail(int id) => '$baseUrl/api/v1/blogs/$id';
  static const String categories = '$baseUrl/api/v1/categories';
  static const String blogs = '$baseUrl/api/v1/blogs';
}
