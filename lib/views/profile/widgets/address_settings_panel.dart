import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/lookup_models.dart';
import 'package:franchisemarketturkiye/viewmodels/address_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/profile_form_fields.dart';

class AddressSettingsPanel extends StatefulWidget {
  final AddressViewModel viewModel;

  const AddressSettingsPanel({super.key, required this.viewModel});

  @override
  State<AddressSettingsPanel> createState() => _AddressSettingsPanelState();
}

class _AddressSettingsPanelState extends State<AddressSettingsPanel> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        if (widget.viewModel.isLoading && widget.viewModel.cities.isEmpty) {
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
              ProfileDropdown<City>(
                label: 'ŞEHİR',
                hint: 'Şehir Seçiniz',
                value: widget.viewModel.selectedCity,
                items: widget.viewModel.cities,
                onChanged: widget.viewModel.onCityChanged,
                itemLabel: (item) => item.name,
              ),
              const SizedBox(height: 16),
              ProfileDropdown<District>(
                label: 'İLÇE',
                hint: 'İlçe Seçiniz',
                value: widget.viewModel.selectedDistrict,
                items: widget.viewModel.districts,
                onChanged: widget.viewModel.onDistrictChanged,
                itemLabel: (item) => item.name,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'MAHALLE',
                controller: widget.viewModel.neighbourhoodController,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'SOKAK / CADDE',
                controller: widget.viewModel.streetController,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                label: 'ADRES DETAYI',
                controller: widget.viewModel.addressDetailController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              if (widget.viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    widget.viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: widget.viewModel.isLoading
                      ? null
                      : () async {
                          final success = await widget.viewModel.saveAddress();
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Adresiniz güncellendi.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD50000),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: widget.viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'KAYDET',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
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
