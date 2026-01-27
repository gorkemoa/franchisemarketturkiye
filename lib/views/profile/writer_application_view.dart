import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/viewmodels/writer_application_view_model.dart';

class WriterApplicationView extends StatefulWidget {
  const WriterApplicationView({super.key});

  @override
  State<WriterApplicationView> createState() => _WriterApplicationViewState();
}

class _WriterApplicationViewState extends State<WriterApplicationView> {
  final WriterApplicationViewModel _viewModel = WriterApplicationViewModel();

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
        title: const Text(
          'Yazar Başvurusu',
        ), // As requested by user "Franchise Başvuruları" though it is writer app
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
                  'Başvuru Formu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aşağıdaki formu doldurarak başvurunuzu bize iletebilirsiniz.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
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

                Row(
                  children: [
                    Expanded(
                      child: _buildTextFieldGroup(
                        label: 'AD *',
                        hint: 'Adınız',
                        controller: _viewModel.firstNameController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFieldGroup(
                        label: 'SOYAD *',
                        hint: 'Soyadınız',
                        controller: _viewModel.lastNameController,
                      ),
                    ),
                  ],
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
                  label: 'SOSYAL MEDYA',
                  hint: 'Instagram, LinkedIn vb.',
                  controller: _viewModel.socialMediaController,
                ),
                const SizedBox(height: 16),

                _buildTextFieldGroup(
                  label: 'ADRES',
                  hint: 'Açık adresiniz',
                  controller: _viewModel.addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                _buildTextFieldGroup(
                  label: 'MESAJINIZ',
                  hint: 'Bize iletmek istediğiniz mesaj...',
                  controller: _viewModel.messageController,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                // CV Upload
                const Text(
                  'CV (PDF, DOC, DOCX)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _viewModel.pickCv,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _viewModel.cvName ?? 'Dosya Seçiniz',
                            style: TextStyle(
                              color: _viewModel.cvName != null
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_viewModel.cvName != null)
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _viewModel.removeCv,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _viewModel.isLoading
                        ? null
                        : () {
                            _viewModel.submitApplication();
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
                            'Başvuruyu Gönder',
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
            keyboardType: keyboardType,
            maxLines: maxLines,
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
