import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:franchisemarketturkiye/viewmodels/writer_application_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/profile_form_fields.dart';

class WriterApplicationPanel extends StatelessWidget {
  final WriterApplicationViewModel viewModel;

  const WriterApplicationPanel({super.key, required this.viewModel});

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

              Row(
                children: [
                  Expanded(
                    child: ProfileTextField(
                      label: 'AD *',
                      controller: viewModel.firstNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ProfileTextField(
                      label: 'SOYAD *',
                      controller: viewModel.lastNameController,
                    ),
                  ),
                ],
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
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'SOSYAL MEDYA',
                controller: viewModel.socialMediaController,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'ADRES',
                controller: viewModel.addressController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'MESAJINIZ',
                controller: viewModel.messageController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // CV
              InkWell(
                onTap: viewModel.pickCv,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.cvName ?? 'CV Yükle (PDF, DOC)',
                          style: TextStyle(
                            color: viewModel.cvName != null
                                ? Colors.black87
                                : Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (viewModel.cvName != null)
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: viewModel.removeCv,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : viewModel.submitApplication,
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
                          'BAŞVUR',
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
