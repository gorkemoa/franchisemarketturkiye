import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/viewmodels/address_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/change_password_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/contact_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/profile_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/writer_application_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/account_info_panel.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/address_settings_panel.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/contact_panel.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/security_settings_panel.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/writer_application_panel.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';

class ProfileView extends StatefulWidget {
  final VoidCallback? onLogout;

  const ProfileView({super.key, this.onLogout});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _profileViewModel;
  late final ChangePasswordViewModel _passwordViewModel;
  late final AddressViewModel _addressViewModel;
  late final WriterApplicationViewModel _writerViewModel;
  late final ContactViewModel _contactViewModel;

  @override
  void initState() {
    super.initState();
    _profileViewModel = ProfileViewModel();
    _passwordViewModel = ChangePasswordViewModel();
    _addressViewModel = AddressViewModel();
    _writerViewModel = WriterApplicationViewModel();
    _contactViewModel = ContactViewModel();
  }

  @override
  void dispose() {
    _profileViewModel.dispose();
    _passwordViewModel.dispose();
    _addressViewModel.dispose();
    _writerViewModel.dispose();
    _contactViewModel.dispose();
    super.dispose();
  }

  final List<String> _sections = [
    'Hesap Bilgilerim',
    'Güvenlik İşlemleri',
    'Adres İşlemleri',
    'Yazar Başvurusu',
    'İletişim',
  ];
  String _selectedSection = 'Hesap Bilgilerim';

  @override
  Widget build(BuildContext context) {
    return GlobalScaffold(
      showBackButton: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSection,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  iconSize: 28,
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: Colors.white,
                  elevation: 4,
                  items: _sections.map((String section) {
                    final isSelected = section == _selectedSection;
                    return DropdownMenuItem<String>(
                      value: section,
                      child: Text(
                        section,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.black87,
                          fontFamily: 'BioSans',
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedSection = newValue;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Dynamic Content Body
            _buildSelectedSection(),

            const SizedBox(height: 40),

            // Logout Button (Always visible at bottom)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _profileViewModel.logout();
                  widget.onLogout?.call();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSection() {
    switch (_selectedSection) {
      case 'Hesap Bilgilerim':
        return AccountInfoPanel(viewModel: _profileViewModel);
      case 'Güvenlik İşlemleri':
        return SecuritySettingsPanel(viewModel: _passwordViewModel);
      case 'Adres İşlemleri':
        return AddressSettingsPanel(viewModel: _addressViewModel);
      case 'Yazar Başvurusu':
        return WriterApplicationPanel(viewModel: _writerViewModel);
      case 'İletişim':
        return ContactPanel(viewModel: _contactViewModel);
      default:
        return AccountInfoPanel(viewModel: _profileViewModel);
    }
  }
}
