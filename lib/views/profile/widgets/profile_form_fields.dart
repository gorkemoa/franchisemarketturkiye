import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(1),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14),
            cursorColor: const Color(0xFFD50000),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;

  const ProfileDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            showProfilePicker(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? itemLabel(value as T) : hint,
                  style: TextStyle(
                    color: value != null
                        ? Colors.black87
                        : Colors.grey.shade400,
                    fontSize: 14,
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
}

void showProfilePicker<T>({
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
    ).showSnackBar(const SnackBar(content: Text('Liste boş.')));
    return;
  }

  final int initialIndex = selectedItem != null
      ? items.indexOf(selectedItem)
      : 0;
  final int safeIndex = initialIndex >= 0 ? initialIndex : 0;
  final FixedExtentScrollController scrollController =
      FixedExtentScrollController(initialItem: safeIndex);
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
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text(
                      'Vazgeç',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text(
                      'Bitti',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: scrollController,
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: items
                      .map((e) => Center(child: Text(itemLabel(e))))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
