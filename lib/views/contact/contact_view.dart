import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/viewmodels/contact_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/contact_panel.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';

import 'package:franchisemarketturkiye/app/app_theme.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  late final ContactViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ContactViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalScaffold(
      showBackButton: true,
      title: const Text('İletişim'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'BİZE ',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextSpan(
                              text: 'ULAŞIN',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sorularınız, önerileriniz ve franchise ile yatırım fırsatlarına dair talepleriniz için bizimle iletişime geçin; birlikte işinizi bir sonraki seviyeye taşıyalım.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ContactPanel(viewModel: _viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
