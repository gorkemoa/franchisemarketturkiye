import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/viewmodels/writer_application_view_model.dart';
import 'package:franchisemarketturkiye/views/profile/widgets/writer_application_panel.dart';

/// Standalone Yazar Başvurusu sayfası.
/// GlobalScaffold import etmez — döngüsel bağımlılıktan kaçınmak için
/// sade Scaffold kullanır.
class WriterApplicationView extends StatefulWidget {
  const WriterApplicationView({super.key});

  @override
  State<WriterApplicationView> createState() => _WriterApplicationViewState();
}

class _WriterApplicationViewState extends State<WriterApplicationView> {
  late final WriterApplicationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = WriterApplicationViewModel();
  }

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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'YAZAR BAŞVURUSU',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'BioSans',
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: WriterApplicationPanel(viewModel: _viewModel),
      ),
    );
  }
}
