import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/views/home/tag_badge.dart';
import 'package:franchisemarketturkiye/views/auth/login_view.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/viewmodels/blog_detail_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogDetailView extends StatefulWidget {
  final int blogId;

  const BlogDetailView({super.key, required this.blogId});

  @override
  State<BlogDetailView> createState() => _BlogDetailViewState();
}

class _BlogDetailViewState extends State<BlogDetailView> {
  late final BlogDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BlogDetailViewModel(blogId: widget.blogId);
    _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (_viewModel.errorMessage != null) {
            return _buildErrorWidget();
          }

          if (_viewModel.blog == null) {
            return const Center(child: Text('Blog bulunamadı'));
          }

          return _buildContent(_viewModel.blog!);
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _viewModel.fetchBlog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Blog blog) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 🏛 Classic Corporate App Bar
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.primaryColor,
          elevation: 0.5,
          surfaceTintColor: Colors.white,
          leadingWidth: 56,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            blog.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),

        // 📝 Content Section
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼 Featured Image below the AppBar
              Image.network(
                blog.imageUrl,
                width: double.infinity,
                height: 240,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 240,
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Date Row
                    Row(
                      children: [
                        if (blog.category != null &&
                            blog.category!.name != null)
                          TagBadge(text: blog.category!.name!),
                        const SizedBox(width: 8),
                        TagBadge(
                          text: blog.type.name ?? '',
                          color: const Color(0xFF666666),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(blog.dateAdded),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Main Title
                    Text(
                      blog.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Minimal Author Section
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: blog.author.imageUrl != null
                              ? NetworkImage(blog.author.imageUrl!)
                              : null,
                          child: blog.author.imageUrl == null
                              ? const Icon(Icons.person, size: 14)
                              : null,
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            blog.author.name ?? 'Yazar Bilgisi Yok',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF444444),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ),

                    // 🌐 HTML RICH CONTENT
                    HtmlWidget(
                      blog.description,
                      onTapUrl: (url) async {
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                          return true;
                        }
                        return false;
                      },
                      textStyle: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF333333),
                        letterSpacing: 0.1,
                      ),
                      customStylesBuilder: (element) {
                        if (element.localName == 'strong' ||
                            element.localName == 'b') {
                          return {'font-weight': '600', 'color': '#000000'};
                        }
                        if (element.localName == 'p') {
                          return {'margin-bottom': '12px'};
                        }
                        if (element.localName == 'h1' ||
                            element.localName == 'h2') {
                          return {
                            'font-weight': '700',
                            'margin-top': '24px',
                            'margin-bottom': '12px',
                          };
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    // Tags Section
                    if (blog.tags.isNotEmpty) ...[
                      const Text(
                        "ETİKETLER",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Color(0xFFBBBBBB),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: blog.tags
                            .split(',')
                            .map(
                              (tag) => TagBadge(
                                text: tag.trim(),
                                color: const Color(0xFF666666),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      "Ocak",
      "Şubat",
      "Mart",
      "Nisan",
      "Mayıs",
      "Haziran",
      "Temmuz",
      "Ağustos",
      "Eylül",
      "Ekim",
      "Kasım",
      "Aralık",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
