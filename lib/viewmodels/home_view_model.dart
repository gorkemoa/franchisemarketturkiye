import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/models/category_blog.dart';
import 'package:franchisemarketturkiye/models/category.dart';
import 'package:franchisemarketturkiye/models/marketing_talk.dart';
import 'package:franchisemarketturkiye/models/banner.dart';
import 'package:franchisemarketturkiye/models/magazine.dart';
import 'package:franchisemarketturkiye/services/banner_service.dart';
import 'package:franchisemarketturkiye/services/blog_service.dart';
import 'package:franchisemarketturkiye/services/category_service.dart';
import 'package:franchisemarketturkiye/services/magazine_service.dart';

class HomeViewModel extends ChangeNotifier {
  static final HomeViewModel _instance = HomeViewModel._internal();
  factory HomeViewModel() => _instance;

  HomeViewModel._internal({
    BlogService? blogService,
    CategoryService? categoryService,
    BannerService? bannerService,
    MagazineService? magazineService,
  }) : _blogService = blogService ?? BlogService(),
       _categoryService = categoryService ?? CategoryService(),
       _bannerService = bannerService ?? BannerService(),
       _magazineService = magazineService ?? MagazineService();

  final BlogService _blogService;
  final CategoryService _categoryService;
  final BannerService _bannerService;
  final MagazineService _magazineService;

  List<Blog> _featuredBlogs = [];
  List<Blog> get featuredBlogs => _featuredBlogs;

  List<Blog> _sliderBlogs = [];
  List<Blog> get sliderBlogs => _sliderBlogs;

  List<CategoryBlog> _selectedCategoryBlogs = [];
  List<CategoryBlog> get selectedCategoryBlogs => _selectedCategoryBlogs;
  List<MarketingTalk> _marketingTalks = [];
  List<MarketingTalk> get marketingTalks => _marketingTalks;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<HomeBanner> _banners = [];
  List<HomeBanner> get banners => _banners;

  List<Magazine> _magazines = [];
  List<Magazine> get magazines => _magazines;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final sliderResult = await _blogService.getSliderBlogs();
    final featuredResult = await _blogService.getFeaturedBlogs();
    final selectedCategoryResult = await _blogService
        .getSelectedCategoryBlogs();
    final marketingTalksResult = await _blogService.getMarketingTalks();
    final categoriesResult = await _categoryService.getCategories();
    final bannersResult = await _bannerService.getBanners();
    final magazinesResult = await _magazineService.getMagazines(limit: 4);

    _isLoading = false;
    if (sliderResult.isSuccess &&
        featuredResult.isSuccess &&
        selectedCategoryResult.isSuccess &&
        marketingTalksResult.isSuccess &&
        categoriesResult.isSuccess &&
        bannersResult.isSuccess &&
        magazinesResult.isSuccess) {
      _sliderBlogs = sliderResult.data ?? [];
      _featuredBlogs = featuredResult.data ?? [];
      _selectedCategoryBlogs = selectedCategoryResult.data ?? [];
      _marketingTalks = marketingTalksResult.data ?? [];
      _categories = List<Category>.from(categoriesResult.data ?? []);
      _banners = bannersResult.data?.data.items ?? [];
      _magazines = magazinesResult.data?.data.items ?? [];
    } else {
      _errorMessage =
          sliderResult.error ??
          featuredResult.error ??
          selectedCategoryResult.error ??
          marketingTalksResult.error ??
          categoriesResult.error ??
          bannersResult.error ??
          magazinesResult.error;
    }
    notifyListeners();
  }

  Future<void> fetchFeaturedBlogs() async => refresh();
}
