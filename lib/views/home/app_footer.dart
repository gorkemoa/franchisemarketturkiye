import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class AppFooter extends StatelessWidget {
  final ValueChanged<int>? onIndexChanged;
  const AppFooter({super.key, this.onIndexChanged});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          SvgPicture.asset(
            'assets/logo.svg',
            height: 40,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 24),
          // Description
          const Text(
            'Franchise Market Türkiye, iş dünyası ve yatırım ekosistemine dair güvenilir içerik sunan lider yayın organıdır.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.6,
              fontFamily: 'BioSans',
            ),
          ),

          const SizedBox(height: 32),

          // Social Icons Section
          const Text(
            'SOSYAL MEDYA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.5,
              fontFamily: 'BioSans',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSocialIcon(
                'assets/hamburger_nav_icons/facebook.svg',
                'https://www.facebook.com/Franchisemtr',
              ),
              _buildSocialIcon(
                'assets/hamburger_nav_icons/instagram.svg',
                'https://www.instagram.com/franchisemarketturkiye/',
              ),
              _buildSocialIcon(
                'assets/hamburger_nav_icons/youtube.svg',
                'https://www.youtube.com/@FranchiseMarketTurkiye',
              ),
              _buildSocialIcon(
                'assets/hamburger_nav_icons/x_twitter.svg',
                'https://x.com/Franchise_MTR',
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: SvgPicture.asset(
          assetPath,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      ),
    );
  }
}
