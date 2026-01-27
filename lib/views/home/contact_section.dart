import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bize Ulaşın',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600, // Inter 600
              color: Colors.black,
              height: 1.55, // 28px line-height / 18px font-size
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sorularınız, önerileriniz ve franchise ile yatırım fırsatlarına dair talepleriniz için bizimle iletişime geçin; birlikte işinizi bir sonraki seviyeye taşıyalım.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              shape: RoundedRectangleBorder(),
              elevation: 0,
            ),
            child: const Text(
              'İletişime Geçin',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
