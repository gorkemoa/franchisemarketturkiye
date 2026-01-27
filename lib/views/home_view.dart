import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/viewmodels/home_view_model.dart';
import 'package:franchisemarketturkiye/views/widgets/blog_card.dart';
import 'package:franchisemarketturkiye/views/widgets/blog_slider.dart';
import 'package:franchisemarketturkiye/views/widgets/category_blog_section.dart';
import 'package:franchisemarketturkiye/views/widgets/marketing_talks_section.dart';
import 'package:franchisemarketturkiye/views/widgets/brand_ticker.dart';
import 'package:franchisemarketturkiye/views/widgets/franchise_files_list.dart';
import 'package:franchisemarketturkiye/views/widgets/contact_section.dart';
import 'package:franchisemarketturkiye/views/widgets/app_footer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/logo.svg',
          height: 30,
          placeholderBuilder: (context) => Text(
            'FRANCHISE MARKET',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () {},
            icon: Container(
              color: AppTheme.primaryColor,
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Center(
                child: SvgPicture.asset('assets/logo.svg', height: 40),
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _viewModel.categories.length,
                    itemBuilder: (context, index) {
                      final category = _viewModel.categories[index];
                      return ListTile(
                        leading:
                            category.imageUrl != null &&
                                category.imageUrl!.endsWith('.svg')
                            ? SvgPicture.network(
                                category.imageUrl!,
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  AppTheme.textPrimary,
                                  BlendMode.srcIn,
                                ),
                              )
                            : const Icon(Icons.category_outlined),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: category.count != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  '${category.count}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          // Navigate to category detail
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
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
                    child: FranchiseFilesList(),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
      ),
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
