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
import 'package:url_launcher/url_launcher.dart';
import 'package:franchisemarketturkiye/viewmodels/author_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/categories_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/search_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/magazines_view_model.dart';
import 'package:franchisemarketturkiye/views/franchise/franchises_view.dart';
import 'package:franchisemarketturkiye/views/auth/login_view.dart';
import 'package:franchisemarketturkiye/views/profile/profile_view.dart';
import 'package:franchisemarketturkiye/viewmodels/franchises_view_model.dart';
import 'package:franchisemarketturkiye/services/link_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _lastProcessedUri;
  DateTime? _lastProcessTime;

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

  /// Handle a raw URL string
  void handleUrl(String url) {
    try {
      final uri = Uri.parse(url);
      _handleUri(uri);
    } catch (e) {
      developer.log('❌ Error parsing URL: $url', name: 'DeepLink', error: e);
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Centralized URI handler
  void _handleUri(Uri uri) {
    // Prevent double processing (common issue with some plugins)
    final now = DateTime.now();
    if (_lastProcessedUri == uri &&
        _lastProcessTime != null &&
        now.difference(_lastProcessTime!).inMilliseconds < 1000) {
      developer.log('⏭️ Skipping duplicate URI: $uri', name: 'DeepLink');
      return;
    }
    _lastProcessedUri = uri;
    _lastProcessTime = now;

    developer.log(
      '🎯 Processing URI: ${uri.path} (Host: ${uri.host})',
      name: 'DeepLink',
    );

    // Support both custom scheme (franchise://) and universal links (https://...)
    final String host = uri.host.toLowerCase();
    final String scheme = uri.scheme.toLowerCase();

    // 1. Handle External Hosts (Dış bağlantıları direkt tarayıcıda aç)
    // Sadece http/https protokolü ve bizim domainimiz olmayan adresleri dışarıda açıyoruz
    if (scheme.startsWith('http') &&
        host.isNotEmpty &&
        !host.contains('franchisemarketturkiye.com')) {
      developer.log('🌍 External link detected: $uri', name: 'DeepLink');
      _launchExternalUrl(uri.toString());
      return;
    }

    final pathSegments = uri.pathSegments;
    // Base URL or root
    if (pathSegments.isEmpty ||
        (pathSegments.length == 1 && pathSegments[0].isEmpty)) {
      developer.log('🏠 Root URL detected', name: 'DeepLink');
      handleNavigation('home', null);
      return;
    }

    final type = pathSegments[0];
    String? id;

    // Try to find an integer ID in segments
    for (int i = 1; i < pathSegments.length; i++) {
      if (int.tryParse(pathSegments[i]) != null) {
        id = pathSegments[i];
        break;
      }
    }

    // Fallback to second segment if no integer ID found
    if (id == null && pathSegments.length > 1) {
      id = pathSegments[1];
    }

    // Resolve slug if needed
    if (int.tryParse(id ?? '') == null && id != null) {
      final String? mappedType = _getMappedType(type);
      if (mappedType != null) {
        developer.log(
          '🔍 Slug detected for $type: $id, resolving...',
          name: 'DeepLink',
        );
        _resolveAndNavigate(mappedType, id, uri.toString());
        return;
      }
    }

    handleNavigation(type, id);
  }

  /// Maps URL types to API-supported types (blog, magazine, franchise)
  String? _getMappedType(String type) {
    type = type.toLowerCase();
    if (['blog', 'news', 'haber', 'haberler'].contains(type)) return 'blog';
    if (['dergi', 'dergiler', 'magazine', 'magazines'].contains(type)) {
      return 'magazine';
    }
    if (['franchise', 'marka', 'markalar', 'markalarımız'].contains(type)) {
      return 'franchise';
    }
    return null;
  }

  /// Resolves a slug via API and navigates to the result
  Future<void> _resolveAndNavigate(
    String type,
    String slug,
    String originalUrl,
  ) async {
    try {
      final result = await LinkService().resolveLink(link: slug, type: type);

      if (result.isSuccess &&
          result.data?.success == true &&
          result.data?.data != null) {
        final data = result.data!.data!;
        developer.log(
          '✅ Resolved: ${data.type} ID: ${data.item.id} for slug: $slug',
          name: 'DeepLink',
        );
        handleNavigation(data.type, data.item.id.toString());
      } else {
        developer.log(
          '❌ Resolve failed for $slug: ${result.error}',
          name: 'DeepLink',
        );
        // Fallback to WebView if resolve fails
        handleNavigation('page', originalUrl);
      }
    } catch (e) {
      developer.log('❌ Error in _resolveAndNavigate: $e', name: 'DeepLink');
      handleNavigation('page', originalUrl);
    }
  }

  /// Centralized navigation logic for Deep Links and Push Notifications
  void handleNavigation(String type, String? id) async {
    developer.log('🚀 Navigating to: $type (ID: $id)', name: 'DeepLink');

    switch (type) {
      case 'home':
        // Ana sayfaya gitmek için navigator'ı en başa çekiyoruz
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
        break;

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

      case 'franchise-dosyasi':
      case 'markalar':
        _push(
          MaterialPageRoute(
            builder: (_) => FranchisesView(
              viewModel: FranchisesViewModel()..fetchFranchises(),
            ),
          ),
        );
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
      case 'yazarlar':
      case 'author':
      case 'authors':
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

        // Dış bağlantı ise tarayıcıda aç
        if (url.startsWith('http') &&
            !url.contains('franchisemarketturkiye.com')) {
          _launchExternalUrl(url);
          return;
        }

        _push(
          MaterialPageRoute(
            builder: (_) => WebViewView(url: url, title: 'Sayfa'),
          ),
        );
        break;

      case 'hesabim':
      case 'profil':
      case 'profile':
        _push(MaterialPageRoute(builder: (_) => const ProfileView()));
        break;

      case 'giris-yap':
      case 'login':
        _push(MaterialPageRoute(builder: (_) => const LoginView()));
        break;

      case 'kayit-ol':
      case 'register':
        _push(
          MaterialPageRoute(
            builder: (_) => const LoginView(initialIsLogin: false),
          ),
        );
        break;

      case 'sifremi-unuttum':
        _push(
          MaterialPageRoute(
            builder: (context) => const WebViewView(
              url: 'https://franchisemarketturkiye.com/sifremi-unuttum',
              title: 'Şifremi Unuttum',
            ),
          ),
        );
        break;

      case 'iletisim':
      case 'contact':
        _push(
          MaterialPageRoute(
            builder: (context) => const WebViewView(
              url: 'https://franchisemarketturkiye.com/iletisim',
              title: 'İletişim',
            ),
          ),
        );
        break;

      case 'hikayemiz':
      case 'about':
        _push(
          MaterialPageRoute(
            builder: (context) => const WebViewView(
              url: 'https://franchisemarketturkiye.com/hikayemiz',
              title: 'Hikayemiz',
            ),
          ),
        );
        break;

      case 'satin-al':
        _push(
          MaterialPageRoute(
            builder: (context) => const WebViewView(
              url: 'https://franchisemarketturkiye.com/satin-al',
              title: 'Satın Al',
            ),
          ),
        );
        break;

      default:
        // Bilinmeyen tür ancak tam bir URL ise tarayıcıda açmayı dene
        if (type.startsWith('http')) {
          _launchExternalUrl(type);
          return;
        }
        developer.log('❓ Unknown navigation type: $type', name: 'DeepLink');
        break;
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        developer.log('🌐 Launching external browser: $url', name: 'DeepLink');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        developer.log(
          '❌ Could not launch external URL: $url',
          name: 'DeepLink',
        );
      }
    } catch (e) {
      developer.log('❌ Error in _launchExternalUrl: $e', name: 'DeepLink');
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
