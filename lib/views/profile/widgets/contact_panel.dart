import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/viewmodels/contact_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/profile_form_fields.dart';

class ContactPanel extends StatelessWidget {
  final ContactViewModel viewModel;

  const ContactPanel({super.key, required this.viewModel});

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
                label: 'AD SOYAD *',
                controller: viewModel.fullNameController,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'TELEFON *',
                controller: viewModel.phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'E-POSTA *',
                controller: viewModel.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'MESAJINIZ *',
                controller: viewModel.messageController,
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : viewModel.sendMessage,
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
                          'GÖNDER',
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
