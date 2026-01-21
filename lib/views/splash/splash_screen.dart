import 'dart:async';
import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/constants/app_colors.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/models/active_user.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/welcome/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<ConsumerStatefulWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Timer(const Duration(seconds: 3), () async {
      try {
        // existing user status (results[1] is the return value of authOperation)
        // The original code directly checks isLoggedIn from AppInitManager.
        // Assuming 'results[1]' is a placeholder for the actual login status check.
        // For now, we'll keep the original login check and integrate the new logic.
        bool isLoggedIn = await AppInitManager.instance.catalystApp
            .isUserLoggedIn();

        if (isLoggedIn) {
          // Pre-fetch current catalystUser details
          // and setting it as the current Active User in the provider for access in whole application
          final catalystUser = await AuthManager.instance.fetchUser();
          if (catalystUser != null) {
            final activeUser = ActiveUserModel.fromCatalystUser(catalystUser);
            ref.read(activeUserRepositoryProvider.notifier).setUser(activeUser);
            
            // Fetch User Profile
            await UserManager.instance.fetchUserProfile(catalystUser.id);
          } else {
            ref.read(activeUserRepositoryProvider.notifier).clear();
          }
          // Fetch access token
          await TokenManager.instance.getToken();
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  isLoggedIn ? const DashboardPage() : const WelcomePage(),
            ),
          );
        }
      } catch (e) {
        // Fallback to Welcome Page on warning/error
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomePage()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/images/FI_logo.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'DSV360',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    // color: Colors.white,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
