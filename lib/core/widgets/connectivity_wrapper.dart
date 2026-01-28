import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/main.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isShowingDialog = false;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _checkStatus(results);
    });

    // Check initial status
    Connectivity().checkConnectivity().then((results) => _checkStatus(results));
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _checkStatus(List<ConnectivityResult> results) {
    bool hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection && !_isShowingDialog) {
      _showNoInternetDialog();
    } else if (hasConnection && _isShowingDialog) {
      _hideNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    if (_isShowingDialog) return;

    _isShowingDialog = true;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.only(top: 30),
          title: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: Colors.red.shade700,
                size: 48,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Bağlantı Hatası',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Uygulamayı kullanabilmek için internet bağlantısına ihtiyacımız var. Lütfen ayarlarınızı kontrol edin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _hideNoInternetDialog() {
    if (_isShowingDialog) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _isShowingDialog = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
