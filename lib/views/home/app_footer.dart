import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

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
            ),
          ),
          const SizedBox(height: 32),
          // Social Icons
          Row(
            children: [
              _buildSocialIcon(Icons.facebook),
              _buildSocialIcon(Icons.camera_alt_outlined), // Instagram
              _buildSocialIcon(Icons.music_note), // TikTok (substitute)
              _buildSocialIcon(Icons.link), // LinkedIn (substitute)
              _buildSocialIcon(Icons.close), // X (substitute)
              _buildSocialIcon(Icons.chat_bubble_outline), // WhatsApp
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Icon(icon, size: 20, color: Colors.black),
    );
  }
}
