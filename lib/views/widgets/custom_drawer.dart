import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/views/contact/contact_view.dart';
import 'package:franchisemarketturkiye/views/profile/profile_view.dart';

class GlobalScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? title;
  final bool showAppBar;
  final bool showBackButton;
  final List<Widget>? actions;
  final int? currentIndex;

  const GlobalScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.title,
    this.showAppBar = true,
    this.showBackButton = false,
    this.actions,
    this.currentIndex,
  });

  @override
  State<GlobalScaffold> createState() => _GlobalScaffoldState();
}

class _GlobalScaffoldState extends State<GlobalScaffold>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _menuController;
  late Animation<Offset> _drawerOffset;
  late Animation<double> _barrierOpacity;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _drawerOffset = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _menuController, curve: Curves.easeOutQuart),
        );

    _barrierOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _menuController, curve: Curves.easeIn));

    // Rebuild when animation status changes to remove/add overlay from tree
    _menuController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed ||
          status == AnimationStatus.completed) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hide AppBar specifically for Profile page (index 4) if used as App Shell
    final bool effectiveShowAppBar = widget.currentIndex == 4
        ? false
        : widget.showAppBar;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: effectiveShowAppBar
          ? AppBar(
              title:
                  widget.title ??
                  SvgPicture.asset('assets/logo.svg', height: 30),
              leading: widget.showBackButton
                  ? IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Colors.black,
                      ),
                    )
                  : null,
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions: [
                if (widget.actions != null) ...widget.actions!,
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: _toggleMenu,
                    icon: _buildAnimatedIcon(),
                  ),
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          // Main Content
          widget.body,

          // Menu Overlay
          if (_isMenuOpen || !_menuController.isDismissed)
            Positioned.fill(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _toggleMenu,
                    child: FadeTransition(
                      opacity: _barrierOpacity,
                      child: Container(color: Colors.black.withOpacity(0.5)),
                    ),
                  ),
                  SlideTransition(
                    position: _drawerOffset,
                    child: const Align(
                      alignment: Alignment.topCenter,
                      child: CustomDrawer(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _menuController,
      builder: (context, child) {
        final color = Color.lerp(
          Colors.black,
          Colors.red,
          _menuController.value,
        );
        return SizedBox(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, -3 + (3 * _menuController.value)),
                child: Transform.rotate(
                  angle: _menuController.value * (3.14159 / 4),
                  child: Container(
                    width: 20,
                    height: 2,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(
                  _menuController.value * -3,
                  3 - (3 * _menuController.value),
                ),
                child: Transform.rotate(
                  angle: _menuController.value * (-3.14159 / 4),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 14 + (6 * _menuController.value),
                      height: 2,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menü Section
                    _buildSectionTitle('MENÜ'),
                    _buildMenuItem(
                      'FRANCHISE DOSYASI',
                      isSelected: true,
                      onTap: () {
                        // TODO: Implement Franchise Dosyasi navigation
                      },
                    ),
                    _buildMenuItem(
                      'YAZARLAR',
                      onTap: () {
                        // In a real app we might want to use a callback to HomeView
                        // or just push/pop. For now, let's just push it as a new view
                        // if we want it to be a standalone page,
                        // but since it's already in the bottom bar,
                        // maybe the drawer should just close and switch tab?
                        // However, CustomDrawer doesn't have access to HomeView's state easily.
                        // I'll push it as a standalone page for now or just add the item.
                      },
                    ),
                    _buildMenuItem('DERGİLER'),
                    _buildMenuItem('HİKAYEMİZ'),
                    _buildMenuItem(
                      'YAZAR BAŞVURUSU',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileView(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      'İLETİŞİM',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactView(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Banner
                    _buildBottomBanner(),

                    const SizedBox(height: 20),

                    // Social Media Section
                    _buildSectionTitle('SOSYAL MEDYA'),
                    _buildSocialMedia(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.5,
              fontFamily: 'BioSans',
            ),
          ),
          const SizedBox(height: 4),
          Container(width: 50, height: 2, color: AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFFFF1F2)
            : Colors.transparent, // Light pink
        borderRadius: BorderRadius.circular(2),
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: isSelected
            ? const Icon(
                Icons.chevron_right,
                color: AppTheme.primaryColor,
                size: 18,
              )
            : null,
        horizontalTitleGap: 0,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600, // SemiBold
            color: isSelected ? AppTheme.primaryColor : Colors.black,
            letterSpacing: 0.3,
            fontFamily: 'BioSans',
          ),
        ),
        onTap:
            onTap ??
            () {
              // TODO: Implement navigation
            },
      ),
    );
  }

  Widget _buildSocialMedia() {
    final socials = [
      'assets/hamburger_nav_icons/facebook.svg',
      'assets/hamburger_nav_icons/instagram.svg',
      'assets/hamburger_nav_icons/youtube.svg',
      'assets/hamburger_nav_icons/x_twitter.svg',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: socials.map((assetPath) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEEEE)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SvgPicture.asset(
              assetPath,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/hamburger_nav_icons/image.png',
              width: double.infinity,
              height: 160, // Match image aspect better
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SUNUM DOSYASI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BioSans',
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
