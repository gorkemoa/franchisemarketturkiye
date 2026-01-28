import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_flipbook/flutter_pdf_flipbook.dart';
import 'package:franchisemarketturkiye/views/widgets/filling_logo_loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class MagazineReaderView extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const MagazineReaderView({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<MagazineReaderView> createState() => _MagazineReaderViewState();
}

class _MagazineReaderViewState extends State<MagazineReaderView> {
  bool _isLandscape = false;
  bool _isLoading = true;
  double _downloadProgress = 0.0;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.pdfUrl));
      final response = await client.send(request);

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final List<int> bytes = [];

      final directory = await getTemporaryDirectory();
      // Generate a filename from the URL or title
      final fileName = widget.pdfUrl
          .split('/')
          .last
          .replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');
      final file = File('${directory.path}/$fileName');

      // If file already exists and has some size, maybe reuse?
      // For now, let's always re-download for fresh progress or simple logic.

      response.stream.listen(
        (value) {
          bytes.addAll(value);
          receivedBytes += value.length;
          if (mounted) {
            setState(() {
              if (totalBytes > 0) {
                _downloadProgress = receivedBytes / totalBytes;
              } else {
                // Indeterminate simulation if contentLength is missing
                _downloadProgress = (_downloadProgress + 0.05).clamp(0.0, 0.99);
              }
            });
          }
        },
        onDone: () async {
          await file.writeAsBytes(bytes);
          if (mounted) {
            setState(() {
              _downloadProgress = 1.0;
              _localPath = file.path;
              _isLoading = false;
            });
          }
          client.close();
        },
        onError: (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Yükleme hatası: $e')));
          }
          client.close();
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });

    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_localPath != null)
            Positioned.fill(
              child: PdfBookViewer(
                pdfUrl: _localPath!,
                style: const PdfBookViewerStyle(
                  loadingIndicatorColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),

          if (_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FillingLogoLoader(size: 150, progress: _downloadProgress),
                  const SizedBox(height: 16),
                  Text(
                    '%${(_downloadProgress * 100).toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // UI Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: _toggleOrientation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isLandscape
                      ? Icons.screen_lock_portrait
                      : Icons.screen_rotation,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
