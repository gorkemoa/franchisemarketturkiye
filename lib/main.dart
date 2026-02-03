import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:franchisemarketturkiye/firebase_options.dart';
import 'package:franchisemarketturkiye/services/notification_service.dart';
import 'package:franchisemarketturkiye/services/deep_link_service.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/core/widgets/connectivity_wrapper.dart';
import 'package:franchisemarketturkiye/views/splash/splash_view.dart';
import 'package:franchisemarketturkiye/views/home/home_view.dart';
import 'package:franchisemarketturkiye/services/auth_service.dart';
import 'package:franchisemarketturkiye/core/network/api_client.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Pdfrx for Flutter
  await pdfrxFlutterInitialize();

  // Initialize Services
  await FirebaseMessagingService.initialize();

  // Setup global unauthorized handler
  ApiClient().onUnauthorized = () async {
    await AuthService().logout();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeView()),
      (route) => false,
    );
  };
  await DeepLinkService().initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: true,
          title: 'Franchise Market Türkiye',
          theme: AppTheme.lightTheme,
          locale: const Locale('tr', 'TR'),
          supportedLocales: const [Locale('tr', 'TR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return ConnectivityWrapper(
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(boldText: false, textScaleFactor: 1.0),
                  child: child!,
                ),
              ),
            );
          },
          home: const SplashView(),
        );
      },
    );
  }
}
