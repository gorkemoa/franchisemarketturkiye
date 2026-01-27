import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/viewmodels/change_password_view_model.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final ChangePasswordViewModel _viewModel = ChangePasswordViewModel();

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
        title: const Text('Güvenlik İşlemleri'),
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
                  'Güvenlik İşlemleri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                if (_viewModel.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.red.shade50,
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
                    color: Colors.green.shade50,
                    width: double.infinity,
                    child: Text(
                      _viewModel.successMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextFieldGroup(
                  label: 'MEVCUT ŞİFRENİZ',
                  hint: 'Mevcut Şifreniz',
                  controller: _viewModel.currentPasswordController,
                ),
                const SizedBox(height: 16),
                _buildTextFieldGroup(
                  label: 'YENİ ŞİFRENİZ',
                  hint: 'Yeni Şifreniz',
                  controller: _viewModel.newPasswordController,
                ),
                const SizedBox(height: 16),
                _buildTextFieldGroup(
                  label: 'YENİ ŞİFRE TEKRAR',
                  hint: 'Yeni Şifre Tekrar',
                  controller: _viewModel.newPasswordConfirmController,
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _viewModel.isLoading
                        ? null
                        : () {
                            _viewModel.updatePassword();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD50000),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
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
                            'Şifremi Güncelle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
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
