import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/viewmodels/change_password_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/profile_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/profile_form_fields.dart';
import 'package:franchisemarketturkiye/core/widgets/app_dialogs.dart';

class SecuritySettingsPanel extends StatelessWidget {
  final ChangePasswordViewModel viewModel;
  final ProfileViewModel profileViewModel;
  final VoidCallback? onLogout;

  const SecuritySettingsPanel({
    super.key,
    required this.viewModel,
    required this.profileViewModel,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, profileViewModel]),
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (viewModel.successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    viewModel.successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ProfileTextField(
                label: 'MEVCUT ŞİFRE',
                controller: viewModel.currentPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'YENİ ŞİFRE',
                controller: viewModel.newPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'YENİ ŞİFRE TEKRAR',
                controller: viewModel.newPasswordConfirmController,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : viewModel.updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'ŞİFREMİ GÜNCELLE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BioSans',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 60),

              // Danger Zone
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HESABI SİL',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'BioSans',
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hesabınızı silmeniz durumunda tüm verileriniz, başvurularınız ve profil bilgileriniz kalıcı olarak silinecektir. Bu işlem geri alınamaz.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: profileViewModel.isLoading
                            ? null
                            : () async {
                                final confirm =
                                    await AppDialogs.showDeleteAccountConfirmation(
                                      context,
                                    );
                                if (confirm) {
                                  final success = await profileViewModel
                                      .deleteAccount();
                                  if (success) {
                                    if (context.mounted) {
                                      AppDialogs.showStatusDialog(
                                        context,
                                        title: 'İŞLEM BAŞARILI',
                                        message: 'Hesabınız başarıyla silindi.',
                                      );
                                      onLogout?.call();
                                    }
                                  } else {
                                    if (context.mounted) {
                                      AppDialogs.showStatusDialog(
                                        context,
                                        title: 'HATA',
                                        message:
                                            profileViewModel.errorMessage ??
                                            'Bir hata oluştu',
                                        isError: true,
                                      );
                                    }
                                  }
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          foregroundColor: AppTheme.primaryColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: profileViewModel.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'HESABIMI KALICI OLARAK SİL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontFamily: 'BioSans',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
