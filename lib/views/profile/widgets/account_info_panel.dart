import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:franchisemarketturkiye/viewmodels/profile_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/profile_form_fields.dart';

class AccountInfoPanel extends StatelessWidget {
  final ProfileViewModel viewModel;

  const AccountInfoPanel({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.customer == null) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ProfileTextField(
                      label: 'AD',
                      controller: viewModel.firstNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ProfileTextField(
                      label: 'SOYAD',
                      controller: viewModel.lastNameController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'TELEFON',
                controller: viewModel.phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 16,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'E-POSTA',
                controller: viewModel.emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: viewModel.newsletter,
                      onChanged: viewModel.setNewsletter,
                      activeColor: Colors.red,
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bülten Aboneliği',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final success = await viewModel.updateProfile();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Profil başarıyla güncellendi'
                                      : viewModel.errorMessage ??
                                            'Bir hata oluştu',
                                ),
                                backgroundColor: success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD50000),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'GÜNCELLE',
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
