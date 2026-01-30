import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class AppDialogs {
  static void showStatusDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isError = false,
    bool isServerError = false,
    VoidCallback? onContactPressed,
  }) {
    String displayMessage = isServerError ? 'Bir Hata oluştu' : message;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        surfaceTintColor: AppTheme.backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          displayMessage,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        actions: [
          if (isServerError)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onContactPressed?.call();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'YARDIM İÇİN BİZE ULAŞIN',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: isError
                  ? AppTheme.secondaryColor
                  : AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'TAMAM',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
