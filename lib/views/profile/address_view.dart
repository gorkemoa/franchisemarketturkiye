import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/lookup_models.dart';
import 'package:franchisemarketturkiye/viewmodels/address_view_model.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  late final AddressViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddressViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Adres İşlemleri'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading && _viewModel.cities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectionGroup<City>(
                  label: 'ŞEHİR',
                  hint: 'Şehir Seçiniz',
                  value: _viewModel.selectedCity,
                  items: _viewModel.cities,
                  onChanged: _viewModel.onCityChanged,
                  itemLabel: (item) => item.name,
                ),
                const SizedBox(height: 16),
                _buildSelectionGroup<District>(
                  label: 'İLÇE',
                  hint: 'İlçe Seçiniz',
                  value: _viewModel.selectedDistrict,
                  items: _viewModel.districts,
                  onChanged: _viewModel.onDistrictChanged,
                  itemLabel: (item) => item.name,
                ),
                const SizedBox(height: 16),
                _buildTextFieldGroup(
                  label: 'MAHALLE',
                  controller: _viewModel.neighbourhoodController,
                ),
                const SizedBox(height: 16),
                _buildTextFieldGroup(
                  label: 'SOKAK / CADDE',
                  controller: _viewModel.streetController,
                ),
                const SizedBox(height: 16),
                _buildTextFieldGroup(
                  label: 'ADRES DETAYI',
                  controller: _viewModel.addressDetailController,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                if (_viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      _viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _viewModel.isLoading
                        ? null
                        : () async {
                            final success = await _viewModel.saveAddress();
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Adresiniz güncellendi.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
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
                    child: _viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Adresi Kaydet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionGroup<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showPicker(
              context: context,
              title: hint,
              items: items,
              selectedItem: value,
              onChanged: onChanged,
              itemLabel: itemLabel,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), // Subtle shadow
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? itemLabel(value) : hint,
                  style: TextStyle(
                    color: value != null
                        ? Colors.black87
                        : Colors.grey.shade400,
                    fontSize: 15,
                    fontWeight: value != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required T? selectedItem,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
  }) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Liste boş')));
      return;
    }

    final int initialIndex = selectedItem != null
        ? items.indexOf(selectedItem)
        : 0;
    final int safeIndex = initialIndex >= 0 ? initialIndex : 0;

    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: safeIndex);

    // Track selection locally until "Done"
    int selectedIndex = safeIndex;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Material(
            // Wrap in Material to fix yellow underlines
            type: MaterialType.transparency,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Stack(
                    // Use Stack for centering
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black, // Explicit color
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              'Vazgeç',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              'Bitti',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                            onPressed: () {
                              if (items.isNotEmpty &&
                                  selectedIndex >= 0 &&
                                  selectedIndex < items.length) {
                                onChanged(items[selectedIndex]);
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      magnification: 1.22,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 30,
                      scrollController: scrollController,
                      onSelectedItemChanged: (int index) {
                        selectedIndex = index;
                      },
                      children: List<Widget>.generate(items.length, (
                        int index,
                      ) {
                        return Center(
                          child: Text(
                            itemLabel(items[index]),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFieldGroup({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            cursorColor: const Color(0xFFD50000),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
