import 'dart:async';
import 'dart:developer' as developer;
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/main.dart';
import 'package:franchisemarketturkiye/views/blog/blog_detail_view.dart';
import 'package:franchisemarketturkiye/views/franchise/franchise_detail_view.dart';
import 'package:franchisemarketturkiye/views/magazine/magazine_reader_view.dart';
import 'package:franchisemarketturkiye/services/magazine_service.dart';
import 'package:franchisemarketturkiye/views/widgets/webview_view.dart';
import 'package:franchisemarketturkiye/views/author/author_detail_view.dart';
import 'package:franchisemarketturkiye/views/category/category_detail_view.dart';
import 'package:franchisemarketturkiye/views/author/authors_view.dart';
import 'package:franchisemarketturkiye/views/category/categories_view.dart';
import 'package:franchisemarketturkiye/views/search/search_view.dart';
import 'package:franchisemarketturkiye/views/magazine/magazines_view.dart';
import 'package:franchisemarketturkiye/viewmodels/author_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/categories_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/search_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/magazines_view_model.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link handling
  Future<void> initialize() async {
    developer.log('🚀 Initializing DeepLink Service', name: 'DeepLink');

    // 1. Handle cold start (app closed -> opened via link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        developer.log(
          '🔗 Initial deep link detected: $initialUri',
          name: 'DeepLink',
        );
        // Small delay to ensure navigator is ready
        Future.delayed(const Duration(milliseconds: 1500), () {
          _handleUri(initialUri);
        });
      }
    } catch (e) {
      developer.log('❌ Error getting initial link', name: 'DeepLink', error: e);
    }

    // 2. Handle links received while app is running (foreground/background)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        developer.log('🔗 Received deep link: $uri', name: 'DeepLink');
        _handleUri(uri);
      },
      onError: (err) {
        developer.log('❌ Error in link stream', name: 'DeepLink', error: err);
      },
    );
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Centralized URI handler
  void _handleUri(Uri uri) {
    developer.log(
      '🎯 Processing URI: ${uri.path} (Host: ${uri.host})',
      name: 'DeepLink',
    );

    // Support both custom scheme (franchise://) and universal links (https://...)
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) {
      developer.log('🏠 Root URL detected', name: 'DeepLink');
      return;
    }

    final type = pathSegments[0];
    final String? id = pathSegments.length > 1 ? pathSegments[1] : null;

    handleNavigation(type, id);
  }

  /// Centralized navigation logic for Deep Links and Push Notifications
  void handleNavigation(String type, String? id) async {
    developer.log('🚀 Navigating to: $type (ID: $id)', name: 'DeepLink');

    switch (type) {
      case 'news':
      case 'haber':
      case 'haberler':
      case 'blog':
        final int? blogId = int.tryParse(id ?? '');
        if (blogId != null) {
          _push(
            MaterialPageRoute(builder: (_) => BlogDetailView(blogId: blogId)),
          );
        }
        break;

      case 'campaign':
      case 'franchise':
      case 'marka':
      case 'ilanhunuleri': // Some site paths might use this
        final int? franchiseId = int.tryParse(id ?? '');
        if (franchiseId != null) {
          _push(
            MaterialPageRoute(
              builder: (_) => FranchiseDetailView(franchiseId: franchiseId),
            ),
          );
        }
        break;

      case 'dergi':
      case 'dergiler':
      case 'magazine':
      case 'magazines':
        final int? magId = int.tryParse(id ?? '');
        if (magId != null) {
          _handleMagazineNavigation(magId);
        } else {
          _push(
            MaterialPageRoute(
              builder: (_) => MagazinesView(
                viewModel: MagazinesViewModel()
                  ..fetchMagazines(isRefresh: true),
              ),
            ),
          );
        }
        break;

      case 'yazar':
      case 'author':
        final int? authorId = int.tryParse(id ?? '');
        if (authorId != null) {
          _push(
            MaterialPageRoute(
              builder: (_) => AuthorDetailView(authorId: authorId),
            ),
          );
        } else {
          _push(
            MaterialPageRoute(
              builder: (_) =>
                  AuthorsView(viewModel: AuthorViewModel()..fetchAuthors()),
            ),
          );
        }
        break;

      case 'kategori':
      case 'category':
        final int? categoryId = int.tryParse(id ?? '');
        if (categoryId != null) {
          _push(
            MaterialPageRoute(
              builder: (_) => CategoryDetailView(categoryId: categoryId),
            ),
          );
        } else {
          _push(
            MaterialPageRoute(
              builder: (_) =>
                  CategoriesView(viewModel: CategoriesViewModel()..init()),
            ),
          );
        }
        break;

      case 'ara':
      case 'search':
        _push(
          MaterialPageRoute(
            builder: (_) => SearchView(
              viewModel: SearchViewModel()..init(),
              categoriesViewModel: CategoriesViewModel()..init(),
            ),
          ),
        );
        break;

      case 'sayfa':
      case 'page':
        final url = (id != null && id.startsWith('http'))
            ? id
            : 'https://franchisemarketturkiye.com/$id';
        _push(
          MaterialPageRoute(
            builder: (_) => WebViewView(url: url, title: 'Sayfa'),
          ),
        );
        break;

      default:
        developer.log('❓ Unknown navigation type: $type', name: 'DeepLink');
        // Handle root or unknown by doing nothing or maybe deep scan path
        break;
    }
  }

  Future<void> _handleMagazineNavigation(int magId) async {
    try {
      final service = MagazineService();
      final result = await service.getMagazineDetail(magId);
      if (result.isSuccess && result.data != null) {
        final magazine = result.data!;
        _push(
          MaterialPageRoute(
            builder: (_) => MagazineReaderView(
              pdfUrl: magazine.fileUrl,
              coverUrl: magazine.imageUrl,
              magazineId: magazine.id,
              title: magazine.title,
            ),
          ),
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error in magazine navigation',
        name: 'DeepLink',
        error: e,
      );
    }
  }

  void _push(Route route) {
    if (navigatorKey.currentState == null) {
      developer.log(
        '⚠️ Navigator state is null, retrying after delay...',
        name: 'DeepLink',
      );
      Future.delayed(const Duration(milliseconds: 500), () => _push(route));
      return;
    }
    navigatorKey.currentState?.push(route);
  }
}
