import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/magazine.dart';
import 'package:franchisemarketturkiye/models/banner.dart';
import 'package:franchisemarketturkiye/viewmodels/home_view_model.dart';
import 'package:franchisemarketturkiye/views/home/blog_card.dart';
import 'package:franchisemarketturkiye/views/home/blog_slider.dart';
import 'package:franchisemarketturkiye/views/home/category_blog_section.dart';
import 'package:franchisemarketturkiye/views/home/marketing_talks_section.dart';
import 'package:franchisemarketturkiye/views/home/franchise_files_list.dart';
import 'package:franchisemarketturkiye/views/home/contact_section.dart';
import 'package:franchisemarketturkiye/views/home/app_footer.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_bottom_nav_bar.dart';
import 'package:franchisemarketturkiye/views/auth/login_view.dart';
import 'package:franchisemarketturkiye/views/profile/profile_view.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';
import 'package:franchisemarketturkiye/views/category/categories_view.dart';
import 'package:franchisemarketturkiye/views/author/authors_view.dart';
import 'package:franchisemarketturkiye/viewmodels/author_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/categories_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/franchises_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/search_view_model.dart';
import 'package:franchisemarketturkiye/views/search/search_view.dart';
import 'package:franchisemarketturkiye/views/franchise/franchises_view.dart';
import 'package:franchisemarketturkiye/views/magazine/magazine_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;
  int _currentIndex = 2; // Home is index 2
  List<Widget> _pages = [];
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;

  late final AuthorViewModel _authorsViewModel;
  late final CategoriesViewModel _categoriesViewModel;
  late final FranchisesViewModel _franchisesViewModel;
  late final SearchViewModel _searchViewModel;
  final GlobalKey<ProfileViewState> _profileKey = GlobalKey<ProfileViewState>();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _authorsViewModel = AuthorViewModel();
    _categoriesViewModel = CategoriesViewModel();
    _franchisesViewModel = FranchisesViewModel();
    _searchViewModel = SearchViewModel();

    // Only load if not already loaded (e.g. by SplashView)
    if (_viewModel.featuredBlogs.isEmpty) {
      _viewModel.init();
    }
    if (_authorsViewModel.authors.isEmpty) {
      _authorsViewModel.fetchAuthors();
    }
    if (_categoriesViewModel.categories.isEmpty) {
      _categoriesViewModel.init();
    }
    if (_franchisesViewModel.franchises.isEmpty) {
      _franchisesViewModel.fetchFranchises();
    }
    if (_searchViewModel.recommendedBlogs.isEmpty) {
      _searchViewModel.init();
    }

    _updatePages();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _updatePages();
      });
    }
  }

  void _updatePages() {
    _pages = [
      AuthorsView(viewModel: _authorsViewModel),
      SearchView(
        viewModel: _searchViewModel,
        categoriesViewModel: _categoriesViewModel,
      ),
      _buildHomeContent(),
      CategoriesView(viewModel: _categoriesViewModel),
      _isLoggedIn
          ? ProfileView(key: _profileKey, onLogout: _checkLoginStatus)
          : LoginView(
              onLoginSuccess: () {
                _checkLoginStatus();
                setState(() => _currentIndex = 2);
              },
            ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GlobalScaffold(
      currentIndex: _currentIndex,
      onIndexChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      showSearch: _currentIndex == 0 || _currentIndex == 3,
      onSearchChanged: (query) {
        if (_currentIndex == 0) {
          _authorsViewModel.setSearchQuery(query);
        } else if (_currentIndex == 1) {
          _searchViewModel.onSearchChanged(query);
        } else if (_currentIndex == 3) {
          _categoriesViewModel.setSearchQuery(query);
        }
      },
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex == index) {
            _onItemTapped(index);
          } else {
            setState(() {
              _currentIndex = index;
            });
            _onItemTapped(index);
          }
        },
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        _authorsViewModel.fetchAuthors();
        break;
      case 1:
        if (_searchViewModel.searchQuery.isNotEmpty) {
          _searchViewModel.search(isRefresh: true);
        } else {
          _searchViewModel.init();
        }
        break;
      case 2:
        _viewModel.refresh();
        break;
      case 3:
        _categoriesViewModel.fetchCategories();
        break;
      case 4:
        _checkLoginStatus();
        if (_isLoggedIn) {
          _profileKey.currentState?.refresh();
        }
        break;
    }
  }

  Widget _buildHomeContent() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_viewModel.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _viewModel.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _viewModel.refresh,
          child: SingleChildScrollView(
            key: const PageStorageKey('home_scroll_key'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic Banners
                ..._viewModel.banners.expand((banner) {
                  if (banner.id == 1 && _viewModel.magazines.isNotEmpty) {
                    return [
                      _buildMagazineHero(context, banner, _viewModel.magazines),
                      SizedBox(height: 16),
                    ];
                  }
                  return [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _buildBannerItem(context, banner.imageUrl),
                    ),
                    SizedBox(height: 16),
                  ];
                }).toList(),

                // Blog Horizontal Slider (Featured Blogs)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 380, // Reduced from 500
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _viewModel.featuredBlogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 280, // Reduced from 320
                            child: BlogCard(
                              blog: _viewModel.featuredBlogs[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Dynamic Slider Moved to Bottom
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ListenableBuilder(
                    listenable: _franchisesViewModel,
                    builder: (context, child) {
                      return FranchiseFilesList(
                        franchises: _franchisesViewModel.franchises,
                        onListAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FranchisesView(
                                viewModel: _franchisesViewModel,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: BlogSlider(blogs: _viewModel.sliderBlogs),
                ),
                SizedBox(height: 16),

                ..._viewModel.selectedCategoryBlogs
                    .take(2)
                    .toList()
                    .asMap()
                    .entries
                    .expand((entry) {
                      final index = entry.key;
                      final section = Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: CategoryBlogSection(categoryBlog: entry.value),
                      );

                      if (index == 0) {
                        return [
                          section,
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              child: Image.asset(
                                'assets/ads_31-22.jpg',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ];
                      }
                      return [section, SizedBox(height: 16)];
                    }),
                // New Marketing Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/panino-1.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Marketing Talks Moved to Bottom
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: MarketingTalksSection(
                    talks: _viewModel.marketingTalks,
                  ),
                ),
                SizedBox(height: 16),

                // Bottom Analysis Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/analiz.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Contact Us Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ContactSection(),
                ),
                SizedBox(height: 16),

                // Bottom Ad Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/02.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Gymboree Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/gymboree.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Footer Section
                AppFooter(
                  onIndexChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMagazineHero(
    BuildContext context,
    HomeBanner banner,
    List<Magazine> magazines,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        child: Container(
          height: 612, // Taller height to accommodate overlay
          decoration: BoxDecoration(color: AppTheme.sliderBackground),
          child: Stack(
            children: [
              // 1. Background Banner Image (The image with logo/text)
              Positioned.fill(
                child: Image.network(
                  banner.imageUrl,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: AppTheme.sliderBackground),
                ),
              ),
              // 2. Magazines Overlayed on top of the image
              Positioned(
                left: 12,
                right: 0,
                bottom: 20,
                child: SizedBox(
                  height: 250, // Container height for the row
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: magazines.take(4).length,
                    itemBuilder: (context, index) {
                      final magazine = magazines[index];
                      final bool isFirst = index == 0;

                      return Align(
                        alignment: Alignment.bottomLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MagazineDetailView(magazineId: magazine.id),
                              ),
                            );
                          },
                          child: Container(
                            width: isFirst ? 90 : 80,
                            height: isFirst ? 110 : 100,
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 15,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                magazine.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.white10,
                                      child: const Icon(
                                        Icons.book,
                                        color: Colors.white24,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerItem(BuildContext context, String imageUrl) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(color: AppTheme.sliderBackground),
      child: ClipRRect(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: AppTheme.sliderBackground),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: AppTheme.sliderBackground),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
