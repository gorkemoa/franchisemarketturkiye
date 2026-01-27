import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class GlobalScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? title;
  final bool showAppBar;

  const GlobalScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.title,
    this.showAppBar = true,
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: widget.showAppBar
          ? AppBar(
              title:
                  widget.title ??
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 30,
                    placeholderBuilder: (context) =>
                        const Text('FRANCHISE MARKET'),
                  ),
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions: [
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
                      color: Colors.black,
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
                        color: Colors.black,
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

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  // Removed static show method as we will use Stack in HomeView for better control

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
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                    _buildSectionTitle('Menü'),
                    _buildMenuItem('FRANCHISE DOSYASI', isSelected: true),
                    _buildMenuItem('DERGİLER'),
                    _buildMenuItem('HİKAYEMİZ'),
                    _buildMenuItem('YAZAR BAŞVURUSU'),
                    _buildMenuItem('İLETİŞİM'),

                    const SizedBox(height: 12),

                    // Kategoriler Section
                    _buildSectionTitle('Kategoriler'),
                    _buildCategoriesGrid(),

                    const SizedBox(height: 12),

                    // Bottom Banner
                    _buildBottomBanner(),

                    const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Container(width: 64, height: 2, color: AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, {bool isSelected = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF5F5F5) : Colors.transparent,
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600, // SemiBold
            color: Colors.black,
            letterSpacing: 0.3,
          ),
        ),
        onTap: () {
          // TODO: Implement navigation
        },
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      _CategoryItem('GENEL', 'assets/hamburger_nav_icons/Frame.svg'),
      _CategoryItem('FRANCHISE', 'assets/hamburger_nav_icons/Frame (1).svg'),
      _CategoryItem('SEKTÖREL', 'assets/hamburger_nav_icons/Frame (2).svg'),
      _CategoryItem('GİRİŞİMCİLİK', 'assets/hamburger_nav_icons/Frame (3).svg'),
      _CategoryItem('TEKNOLOJİ', 'assets/hamburger_nav_icons/Frame (4).svg'),
      _CategoryItem(
        'SOSYAL SORUMLULUK',
        'assets/hamburger_nav_icons/Frame (5).svg',
      ),
      _CategoryItem('ATAMA', 'assets/hamburger_nav_icons/Frame (6).svg'),
      _CategoryItem(
        'RESTORAN & KAFE',
        'assets/hamburger_nav_icons/Frame (7).svg',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.8, // Thinner vertically
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected =
              index == 0; // "GENEL" is selected in the image

          return Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF9F9F9) : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFEEEEEE)
                    : Colors.transparent,
                width: 0.5,
              ),
            ),
            child: InkWell(
              onTap: () {},
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  SvgPicture.asset(category.iconPath, width: 16, height: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          ClipRRect(
            child: Image.asset(
              'assets/FRANCHISE-WB-31-2.jpg',
              width: double.infinity,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SUNUM DOSYASI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 11,
                      ),
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

class _CategoryItem {
  final String title;
  final String iconPath;

  _CategoryItem(this.title, this.iconPath);
}
