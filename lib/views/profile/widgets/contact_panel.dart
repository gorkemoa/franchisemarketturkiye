import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:franchisemarketturkiye/viewmodels/contact_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/profile_form_fields.dart';
import 'package:franchisemarketturkiye/core/widgets/app_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

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
              ProfileTextField(
                label: 'AD SOYAD *',
                controller: viewModel.fullNameController,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'TELEFON *',
                controller: viewModel.phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 16,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'E-POSTA *',
                controller: viewModel.emailController,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect: false,
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
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          await viewModel.sendMessage();
                          if (context.mounted) {
                            final bool success =
                                viewModel.successMessage != null;
                            AppDialogs.showStatusDialog(
                              context,
                              title: success ? 'Başarılı' : 'Hata',
                              message: success
                                  ? viewModel.successMessage!
                                  : (viewModel.errorMessage ??
                                        'Bir hata oluştu.'),
                              isError: !success,
                              isServerError: viewModel.lastStatusCode == 500,
                              onContactPressed: () {
                                launchUrl(
                                  Uri.parse(
                                    'mailto:info@franchisemarketturkiye.com',
                                  ),
                                );
                              },
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD50000),
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
