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
import 'package:franchisemarketturkiye/views/contact/contact_view.dart';

import 'package:upgrader/upgrader.dart';

class HomeView extends StatefulWidget {
  final int initialIndex;
  final String? initialProfileSection;

  const HomeView({
    super.key,
    this.initialIndex = 2,
    this.initialProfileSection,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;
  late int _currentIndex;
  List<Widget> _pages = [];
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;

  late final AuthorViewModel _authorsViewModel;
  late final CategoriesViewModel _categoriesViewModel;
  late final FranchisesViewModel _franchisesViewModel;
  late final SearchViewModel _searchViewModel;
  final GlobalKey<ProfileViewState> _profileKey = GlobalKey<ProfileViewState>();

  late final Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _upgrader = Upgrader(
      debugLogging: true,
      messages: UpgraderMessages(code: 'tr'),
    );
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
          ? ProfileView(
              key: _profileKey,
              onLogout: _checkLoginStatus,
              initialSection: widget.initialProfileSection,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            )
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
    return Theme(
      data: Theme.of(context).copyWith(
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          contentTextStyle: TextStyle(color: Colors.black87, fontSize: 14),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: UpgradeAlert(
        upgrader: _upgrader,
        child: GlobalScaffold(
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
          onProfileSectionSelected: (section) {
            setState(() {
              _currentIndex = 4;
            });
            if (_isLoggedIn) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _profileKey.currentState?.selectSection(section);
              });
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
        ),
      ),
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
                ..._buildResponsiveBanners(context),

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

                // Marketing Talks Moved to Bottom
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: MarketingTalksSection(
                    talks: _viewModel.marketingTalks,
                  ),
                ),
                SizedBox(height: 16),

                // Contact Us Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ContactSection(
                    onContactPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactView(),
                        ),
                      );
                    },
                  ),
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

  List<Widget> _buildResponsiveBanners(BuildContext context) {
    if (_viewModel.banners.isEmpty) return [];

    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    List<Widget> children = [];

    final bannerList = _viewModel.banners;
    final magazines = _viewModel.magazines;

    // Separate hero from others
    HomeBanner? hero;
    final List<HomeBanner> others = [];

    for (var b in bannerList) {
      if (b.id == 1 && magazines.isNotEmpty) {
        hero = b;
      } else {
        others.add(b);
      }
    }

    if (hero != null) {
      children.add(_buildMagazineHero(context, hero, magazines));
      children.add(const SizedBox(height: 16));
    }

    if (others.isNotEmpty) {
      if (isTablet) {
        // Pairs for tablets (side-by-side)
        for (int i = 0; i < others.length; i += 2) {
          if (i + 1 < others.length) {
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBannerItem(context, others[i].imageUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBannerItem(context, others[i + 1].imageUrl),
                    ),
                  ],
                ),
              ),
            );
          } else {
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildBannerItem(context, others[i].imageUrl),
              ),
            );
          }
          children.add(const SizedBox(height: 16));
        }
      } else {
        // Single for phones
        for (final banner in others) {
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildBannerItem(context, banner.imageUrl),
            ),
          );
          children.add(const SizedBox(height: 16));
        }
      }
    }

    return children;
  }

  Widget _buildMagazineHero(
    BuildContext context,
    HomeBanner banner,
    List<Magazine> magazines,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375).clamp(0.8, 2.5);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        child: AspectRatio(
          aspectRatio: 375 / 550,
          child: Container(
            decoration: BoxDecoration(color: AppTheme.sliderBackground),
            child: Stack(
              children: [
                // 1. Background Banner Image
                Positioned.fill(
                  child: Image.network(
                    banner.imageUrl,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppTheme.sliderBackground),
                  ),
                ),
                // 2. Magazines Overlayed
                Positioned(
                  left: 12 * scaleFactor,
                  right: 0,
                  bottom: 20 * scaleFactor,
                  child: SizedBox(
                    height: 250 * scaleFactor,
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
                                  builder: (context) => MagazineDetailView(
                                    magazineId: magazine.id,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: (isFirst ? 100 : 90) * scaleFactor,
                              height: (isFirst ? 150 : 120) * scaleFactor,
                              margin: EdgeInsets.only(right: 12 * scaleFactor),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  4 * scaleFactor,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.6),
                                    blurRadius: 15 * scaleFactor,
                                    offset: Offset(
                                      4 * scaleFactor,
                                      4 * scaleFactor,
                                    ),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  4 * scaleFactor,
                                ),
                                child: Image.network(
                                  magazine.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.white10,
                                        child: Icon(
                                          Icons.book,
                                          color: Colors.white24,
                                          size: 32 * scaleFactor,
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
      ),
    );
  }

  Widget _buildBannerItem(BuildContext context, String imageUrl) {
    return AspectRatio(
      aspectRatio: 375 / 180,
      child: Container(
        decoration: BoxDecoration(color: AppTheme.sliderBackground),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
