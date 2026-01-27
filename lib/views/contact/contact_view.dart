import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/viewmodels/contact_view_model.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final ContactViewModel _viewModel = ContactViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('İletişim'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bize Ulaşın',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'BioSans',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aşağıdaki formu doldurarak bizimle iletişime geçebilirsiniz.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'BioSans',
                  ),
                ),
                const SizedBox(height: 24),

                if (_viewModel.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    child: Text(
                      _viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_viewModel.successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    child: Text(
                      _viewModel.successMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextFieldGroup(
                  label: 'AD SOYAD *',
                  hint: 'Adınız Soyadınız',
                  controller: _viewModel.fullNameController,
                ),
                const SizedBox(height: 16),

                _buildTextFieldGroup(
                  label: 'TELEFON *',
                  hint: '+90...',
                  controller: _viewModel.phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                _buildTextFieldGroup(
                  label: 'E-POSTA *',
                  hint: 'E-posta adresiniz',
                  controller: _viewModel.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildTextFieldGroup(
                  label: 'MESAJINIZ *',
                  hint: 'Bize iletmek istediğiniz mesaj...',
                  controller: _viewModel.messageController,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _viewModel.isLoading
                        ? null
                        : () {
                            _viewModel.sendMessage();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _viewModel.isLoading
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BioSans',
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextFieldGroup({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            fontFamily: 'BioSans',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, fontFamily: 'BioSans'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontFamily: 'BioSans',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
