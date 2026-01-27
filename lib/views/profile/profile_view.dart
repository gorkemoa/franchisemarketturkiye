import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/viewmodels/profile_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/address_view.dart';

class ProfileView extends StatefulWidget {
  final VoidCallback? onLogout;

  const ProfileView({super.key, this.onLogout});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Hesabım'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading && _viewModel.customer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null && _viewModel.customer == null) {
            return Center(child: Text(_viewModel.errorMessage!));
          }

          if (_viewModel.customer == null) {
            return const Center(child: SizedBox());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting and User Title
                Text(
                  '${_viewModel.firstNameController.text} ${_viewModel.lastNameController.text}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),

                // Section Title
                const Text(
                  'Hesap Bilgilerim',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Form
                _buildForm(),

                const SizedBox(height: 48),

                // Navigation Items (Sidebar items adapted)
                _buildMenuItem(
                  icon: Icons.shield_outlined,
                  title: 'Güvenlik İşlemleri',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Adres İşlemleri',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressView(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.storefront_outlined,
                  title: 'Franchise Başvuruları',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Çıkış Yap',
                  onTap: () async {
                    await _viewModel.logout();
                    widget.onLogout?.call();
                  },
                  isDestructive: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextFieldGroup(
                label: 'AD',
                controller: _viewModel.firstNameController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFieldGroup(
                label: 'SOYAD',
                controller: _viewModel.lastNameController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextFieldGroup(
          label: 'TELEFON',
          controller: _viewModel.phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextFieldGroup(
          label: 'E-POSTA',
          controller: _viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _viewModel.newsletter,
                onChanged: _viewModel.setNewsletter,
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
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement update
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD50000), // Red color from image
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text(
              'Bilgilerini Güncelle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldGroup({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
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
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}
