import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/services/magazine_service.dart';

class MagazineReaderViewModel extends ChangeNotifier {
  MagazineReaderViewModel({MagazineService? magazineService});

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
      // pdfrx kütüphanesi kendi içinde stream desteklediği için
      // dosyayı komple RAM'e indirmek (byte list olarak tutmak)
      // özellikle büyük dergilerde RAM dolmasına ve uygulamanın çökmesine neden oluyor.
      // Bu yüzden doğrudan PDF görüntüsüne geçiyoruz.
      _isLoading = false;
      _showPdf = true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _showPdf = true;
    }
    notifyListeners();
  }
}
