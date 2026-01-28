import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/magazine_service.dart';

class MagazineReaderViewModel extends ChangeNotifier {
  final MagazineService _magazineService;

  MagazineReaderViewModel({MagazineService? magazineService})
    : _magazineService = magazineService ?? MagazineService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _showPdf = false;
  bool get showPdf => _showPdf;

  Future<void> preloadAndShow(String pdfUrl) async {
    _isLoading = true;
    _downloadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sadece progres takibi yapıyoruz, dosyayı kaydetmiyoruz (README uyumlu)
      await _magazineService.downloadMagazine(
        pdfUrl,
        onProgress: (progress) {
          _downloadProgress = progress;
          notifyListeners();
        },
      );

      // İndirme bittiğinde logoyu kaldırıp kütüphaneyi gösteriyoruz
      _isLoading = false;
      _showPdf = true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _showPdf = true; // Hata olsa da kütüphane kendi denesin
    }
    notifyListeners();
  }
}
