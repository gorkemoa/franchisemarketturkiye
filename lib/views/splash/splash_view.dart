import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/views/home/home_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:franchisemarketturkiye/viewmodels/home_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/author_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/categories_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/franchises_view_model.dart';
import 'package:franchisemarketturkiye/viewmodels/search_view_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _navigateToHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() async {
    // Start loading data
    final startTime = DateTime.now();

    try {
      // Parallel loading of all main data
      await Future.wait([
        HomeViewModel().init(),
        AuthorViewModel().fetchAuthors(),
        CategoriesViewModel().init(),
        FranchisesViewModel().fetchFranchises(),
        SearchViewModel().init(),
      ]);
    } catch (e) {
      debugPrint('Error loading splash data: $e');
      // Continue anyway, HomeView has its own error handling
    }

    final endTime = DateTime.now();
    final elapsed = endTime.difference(startTime);
    final remaining = const Duration(seconds: 4) - elapsed;

    // Minimum 4 seconds splash or until data is loaded if it takes longer
    if (remaining.inMilliseconds > 0) {
      await Future.delayed(remaining);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: SizedBox(
            width: 250.w,
            height: 250.w,
            child: Image.asset('assets/splash/gif.gif', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
