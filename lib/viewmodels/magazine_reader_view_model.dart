import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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

  String? _localPath;
  String? get localPath => _localPath;

  Future<void> preloadAndShow(String pdfUrl) async {
    _isLoading = true;
    _downloadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(pdfUrl));
      final response = await client.send(request);

      final total = response.contentLength ?? 0;
      int received = 0;

      final tempDir = await getTemporaryDirectory();
      final fileName = 'mag_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${tempDir.path}/$fileName');

      final IOSink sink = file.openWrite();

      await for (var chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total != 0) {
          _downloadProgress = received / total;
          notifyListeners();
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      _localPath = file.path;
      _downloadProgress = 1.0;
      _isLoading = false;
      _showPdf = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Download Error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      _showPdf = false;
      notifyListeners();
    }
  }
}
