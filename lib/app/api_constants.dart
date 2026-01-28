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
  static const String login = '$baseUrl/api/v1/customers/login';
  static const String register = '$baseUrl/api/v1/customers/register';
  static const String customersMe = '$baseUrl/api/v1/customers/me';
  static const String cities = '$baseUrl/api/v1/cities';
  static String districts(String cityId) =>
      '$baseUrl/api/v1/cities/$cityId/districts';
  static const String updateAddress = '$baseUrl/api/v1/customers/address';
  static const String updatePassword = '$baseUrl/api/v1/customers/password';
  static const String writerApplications =
      '$baseUrl/api/v1/writer-applications';
  static const String contact = '$baseUrl/api/v1/contact';
  static String categoryDetail(int id) => '$baseUrl/api/v1/categories/$id';
  static String categoryBlogs(int id) => '$baseUrl/api/v1/categories/$id/blogs';
  static const String authors = '$baseUrl/api/v1/authors';
  static String authorDetail(int id) => '$baseUrl/api/v1/authors/$id';
  static String authorBlogs(int id) => '$baseUrl/api/v1/authors/$id/blogs';
  static const String updateProfile = '$baseUrl/api/v1/customers/profile';
  static const String franchises = '$baseUrl/api/v1/franchises';
  static const String franchiseCategories =
      '$baseUrl/api/v1/franchise-categories';
  static const String searchBlogs = '$baseUrl/api/v1/blogs/search';
}
