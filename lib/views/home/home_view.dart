import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/viewmodels/home_view_model.dart';
import 'package:franchisemarketturkiye/views/home/blog_card.dart';
import 'package:franchisemarketturkiye/views/home/blog_slider.dart';
import 'package:franchisemarketturkiye/views/home/category_blog_section.dart';
import 'package:franchisemarketturkiye/views/home/marketing_talks_section.dart';
import 'package:franchisemarketturkiye/views/home/brand_ticker.dart';
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
import 'package:franchisemarketturkiye/views/franchise/franchises_view.dart';
import 'package:franchisemarketturkiye/viewmodels/author_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/categories_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/franchises_view_model.dart';

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

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _authorsViewModel = AuthorViewModel();
    _categoriesViewModel = CategoriesViewModel();
    _franchisesViewModel = FranchisesViewModel();

    _viewModel.init();
    _authorsViewModel.fetchAuthors();
    _categoriesViewModel.init();
    _franchisesViewModel.fetchFranchises();

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
      const Center(child: Text('Arama')),
      _buildHomeContent(),
      CategoriesView(viewModel: _categoriesViewModel),
      _isLoggedIn
          ? ProfileView(onLogout: _checkLoginStatus)
          : LoginView(onLoginSuccess: _checkLoginStatus),
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
        } else if (_currentIndex == 3) {
          _categoriesViewModel.setSearchQuery(query);
        }
      },
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildStaticSlider(context, 'assets/hero_2.jpg'),
                ),
                const SizedBox(height: 16),

                // Second Static Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildStaticSlider(
                    context,
                    'assets/FRANCHISE-WB-31-2.jpg',
                  ),
                ),
                const SizedBox(height: 16),

                // Brand Ticker Section (Full Width)
                const BrandTicker(),
                const SizedBox(height: 16),

                // Blog Horizontal Slider (Featured Blogs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 380, // Reduced from 500
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _viewModel.featuredBlogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
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
                const SizedBox(height: 16),

                // Dynamic Slider Moved to Bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlogSlider(blogs: _viewModel.sliderBlogs),
                ),
                const SizedBox(height: 16),

                ..._viewModel.selectedCategoryBlogs
                    .take(2)
                    .toList()
                    .asMap()
                    .entries
                    .expand((entry) {
                      final index = entry.key;
                      final section = Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CategoryBlogSection(categoryBlog: entry.value),
                      );

                      if (index == 0) {
                        return [
                          section,
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              child: Image.asset(
                                'assets/ads_31-22.jpg',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ];
                      }
                      return [section, const SizedBox(height: 16)];
                    }),
                // New Marketing Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/panino-1.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Marketing Talks Moved to Bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MarketingTalksSection(
                    talks: _viewModel.marketingTalks,
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom Analysis Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/analiz.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Us Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ContactSection(),
                ),
                const SizedBox(height: 16),

                // Bottom Ad Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/02.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gymboree Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/gymboree.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Footer Section
                const AppFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaticSlider(BuildContext context, String imagePath) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(color: AppTheme.sliderBackground),
      child: ClipRRect(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                imagePath,
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
