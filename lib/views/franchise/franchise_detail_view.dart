import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/franchise.dart';
import 'package:franchisemarketturkiye/models/lookup_models.dart';
import 'package:franchisemarketturkiye/viewmodels/franchise_detail_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/profile_form_fields.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';

class FranchiseDetailView extends StatefulWidget {
  final int franchiseId;

  const FranchiseDetailView({super.key, required this.franchiseId});

  @override
  State<FranchiseDetailView> createState() => _FranchiseDetailViewState();
}

class _FranchiseDetailViewState extends State<FranchiseDetailView> {
  late final FranchiseDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FranchiseDetailViewModel(franchiseId: widget.franchiseId);
    _viewModel.fetchFranchiseDetail();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return GlobalScaffold(
          title: Text(
            _viewModel.franchise?.title ?? 'Yükleniyor...',
            style: const TextStyle(
              fontFamily: 'BioSans',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          showBackButton: true,
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_viewModel.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _viewModel.fetchFranchiseDetail(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final franchise = _viewModel.franchise;
    if (franchise == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo Section
          Container(
            color: const Color(0xFFF9F9F9),
            height: 250,
            child: Image.network(
              franchise.logoUrl,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.business, size: 60, color: Colors.grey),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                _buildInfoCard(franchise),
                const SizedBox(height: 16),

                // Action Button
                ElevatedButton(
                  onPressed: () => _showApplyForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Hemen Başvurun',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                HtmlWidget(
                  franchise.description,
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Franchise franchise) {
    // Filter options where value is not empty
    final activeOptions = franchise.options
        .where((opt) => opt.value.trim().isNotEmpty)
        .toList();

    if (activeOptions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: activeOptions.map((opt) => _buildOptionRow(opt)).toList(),
      ),
    );
  }

  Widget _buildOptionRow(FranchiseOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(4),
            child: SvgPicture.asset(
              'assets/franchise_icon/${option.icon}',
              placeholderBuilder: (context) => option.iconUrl.endsWith('.svg')
                  ? SvgPicture.network(
                      option.iconUrl,
                      placeholderBuilder: (context) => const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                    )
                  : Image.network(
                      option.iconUrl,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyForm() async {
    final firstnameController = TextEditingController();
    final lastnameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final descriptionController = TextEditingController();

    City? selectedCity;
    District? selectedDistrict;

    // Prefill user data if possible
    final userResult = await _viewModel.getCurrentUser();
    if (userResult != null &&
        userResult.success &&
        userResult.data?.customer != null) {
      final user = userResult.data!.customer!;
      firstnameController.text = user.firstname ?? '';
      lastnameController.text = user.lastname ?? '';
      phoneController.text = user.phone ?? '';
      emailController.text = user.email ?? '';
    } else {
      phoneController.text = '0';
    }

    _viewModel.fetchCities();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Başvuru Formu',
                              style: TextStyle(
                                fontFamily: 'BioSans',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ProfileTextField(
                                label: 'Ad',
                                controller: firstnameController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ProfileTextField(
                                label: 'Soyad',
                                controller: lastnameController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ProfileTextField(
                          label: 'E-posta',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                        const SizedBox(height: 16),
                        ProfileTextField(
                          label: 'Telefon',
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 11,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ProfileDropdown<City>(
                                label: 'Şehir',
                                hint: 'Şehir Seçin',
                                value: selectedCity,
                                items: _viewModel.cities,
                                itemLabel: (city) => city.name,
                                onChanged: (city) {
                                  setModalState(() {
                                    selectedCity = city;
                                    selectedDistrict = null;
                                  });
                                  if (city != null) {
                                    _viewModel.fetchDistricts(city.id);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ProfileDropdown<District>(
                                label: 'İlçe',
                                hint: 'İlçe Seçin',
                                value: selectedDistrict,
                                items: _viewModel.districts,
                                itemLabel: (district) => district.name,
                                onChanged: (district) {
                                  setModalState(() {
                                    selectedDistrict = district;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ProfileTextField(
                          label: 'Mesajınız',
                          controller: descriptionController,
                          maxLines: 4,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _viewModel.isApplying
                              ? null
                              : () async {
                                  if (firstnameController.text.isEmpty ||
                                      lastnameController.text.isEmpty ||
                                      emailController.text.isEmpty ||
                                      phoneController.text.isEmpty ||
                                      selectedCity == null ||
                                      selectedDistrict == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Lütfen tüm alanları doldurun.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  final success = await _viewModel
                                      .applyToFranchise(
                                        firstname: firstnameController.text,
                                        lastname: lastnameController.text,
                                        phone: phoneController.text,
                                        email: emailController.text,
                                        city:
                                            int.tryParse(selectedCity!.id) ?? 0,
                                        district:
                                            int.tryParse(
                                              selectedDistrict!.id,
                                            ) ??
                                            0,
                                        description: descriptionController.text,
                                      );

                                  if (!mounted) return;

                                  if (success) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Başvurunuz başarıyla alındı.',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _viewModel.errorMessage ??
                                              'Başvuru sırasında bir hata oluştu.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const RoundedRectangleBorder(),
                            elevation: 0,
                          ),
                          child: _viewModel.isApplying
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Başvuruyu Tamamla',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
