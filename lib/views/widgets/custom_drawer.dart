import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          // Header with Logo and Close Button
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
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

                  const SizedBox(height: 24),

                  // Kategoriler Section
                  _buildSectionTitle('Kategoriler'),
                  _buildCategoriesGrid(),

                  const SizedBox(height: 24),

                  // Bottom Banner
                  _buildBottomBanner(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset('assets/logo.svg', height: 30),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, {bool isSelected = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF5F5F5) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600, // SemiBold
            color: Colors.black,
            letterSpacing: 0.5,
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
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected =
              index == 0; // "GENEL" is selected in the image

          return Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF5F5F5) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: InkWell(
              onTap: () {},
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  SvgPicture.asset(category.iconPath, width: 24, height: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600, // SemiBold
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
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/panino-1.jpg', // Using panino-1 as a placeholder or close match
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 14,
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
