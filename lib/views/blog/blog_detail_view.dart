import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/views/home/tag_badge.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';
import 'package:franchisemarketturkiye/models/blog.dart';
import 'package:franchisemarketturkiye/viewmodels/blog_detail_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogDetailView extends StatefulWidget {
  final int blogId;

  const BlogDetailView({super.key, required this.blogId});

  @override
  State<BlogDetailView> createState() => _BlogDetailViewState();
}

class _BlogDetailViewState extends State<BlogDetailView>
    with SingleTickerProviderStateMixin {
  late final BlogDetailViewModel _viewModel;
  late final AnimationController _searchAnimationController;
  late final Animation<double> _searchHeightAnimation;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = false;
  int _currentMatchIndex = 0;
  List<int> _matchPositions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _viewModel = BlogDetailViewModel(blogId: widget.blogId);
    _viewModel.init();

    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchHeightAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
        _searchQuery = '';
        _matchPositions = [];
        _currentMatchIndex = 0;
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentMatchIndex = 0;
      _updateMatchPositions();
    });
  }

  void _updateMatchPositions() {
    if (_searchQuery.isEmpty || _viewModel.blog == null) {
      _matchPositions = [];
      return;
    }

    final content = _viewModel.blog!.description.toLowerCase();
    final query = _searchQuery.toLowerCase();
    _matchPositions = [];
    int index = content.indexOf(query);
    while (index != -1) {
      _matchPositions.add(index);
      index = content.indexOf(query, index + 1);
    }

    if (_matchPositions.isNotEmpty) {
      _currentMatchIndex = 1;
      _scrollToMatch();
    }
  }

  void _nextMatch() {
    if (_matchPositions.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex % _matchPositions.length) + 1;
      _scrollToMatch();
    });
  }

  void _previousMatch() {
    if (_matchPositions.isEmpty) return;
    setState(() {
      _currentMatchIndex =
          (_currentMatchIndex - 2 + _matchPositions.length) %
              _matchPositions.length +
          1;
      _scrollToMatch();
    });
  }

  void _scrollToMatch() {
    if (_matchPositions.isEmpty || _currentMatchIndex == 0) return;

    // Simple estimation of scroll position based on character index
    final content = _viewModel.blog!.description;
    final position = _matchPositions[_currentMatchIndex - 1];
    final ratio = position / content.length;

    // Wait for frame to ensure content is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        // Adjust the ratio a bit because of header, images etc.
        // This is an estimation since we don't have exact widget positions
        _scrollController.animateTo(
          maxScroll * ratio + 100, // +100 to offset header/image roughly
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _getHighlightedHtml(String html) {
    if (_searchQuery.isEmpty) return html;

    // Filter to only match text outside of HTML tags
    final escapedQuery = RegExp.escape(_searchQuery);
    final regex = RegExp('(?![^<>]*>)$escapedQuery', caseSensitive: false);

    int count = 0;
    return html.splitMapJoin(
      regex,
      onMatch: (m) {
        count++;
        final isCurrent = count == _currentMatchIndex;
        // Current match is gold, others are bright yellow
        final color = isCurrent ? '#FFD700' : '#FFFF00';
        return '<mark id="match-$count" style="background-color: $color; color: black; padding: 0 2px; border-radius: 2px; font-weight: bold;">${m.group(0)}</mark>';
      },
      onNonMatch: (n) => n,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return GlobalScaffold(
          showBackButton: true,
          actions: [
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(
                _isSearchVisible ? Icons.close : Icons.search,
                color: Colors.black,
              ),
            ),
          ],
          body: Column(
            children: [
              SizeTransition(
                sizeFactor: _searchHeightAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Arama yapın...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.search, size: 20),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      if (_matchPositions.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '$_currentMatchIndex/${_matchPositions.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: _previousMatch,
                          icon: const Icon(Icons.keyboard_arrow_up),
                        ),
                        IconButton(
                          onPressed: _nextMatch,
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
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
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
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
                    if (blog.category != null && blog.category!.name != null)
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
                  _getHighlightedHtml(blog.description),
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
