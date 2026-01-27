import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/viewmodels/change_password_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/profile_form_fields.dart';

class SecuritySettingsPanel extends StatelessWidget {
  final ChangePasswordViewModel viewModel;

  const SecuritySettingsPanel({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
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
                    backgroundColor: const Color(0xFFD50000),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
