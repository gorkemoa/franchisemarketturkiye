import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class ContactSection extends StatelessWidget {
  final VoidCallback? onContactPressed;
  const ContactSection({super.key, this.onContactPressed});

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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'BİZE ',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: 'ULAŞIN',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sorularınız, önerileriniz ve franchise ile yatırım fırsatlarına dair talepleriniz için bizimle iletişime geçin; birlikte işinizi bir sonraki seviyeye taşıyalım.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContactPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
              ),
              child: const Text(
                'İletişime Geçin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
