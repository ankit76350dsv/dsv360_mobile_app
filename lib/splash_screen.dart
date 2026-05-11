import 'dart:async';
import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/core/models/active_user.dart';
import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/core/cache/user_cache_provider.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/core/welcome/welcome_page.dart';
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
      duration: const Duration(milliseconds: 0),
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

    Timer(const Duration(seconds: 0), () async {
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

            // Fetch User Profile (also writes extended fields to SharedPrefs cache)
            await UserManager.instance.fetchUserProfile(catalystUser.id);

            // Populate the centralised cache provider so every page can read
            // user data (id, name, role, email, etc.) from local cache.
            await ref.read(globalUserProvider.notifier).refresh();
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
    final theme = Theme.of(context);
    final customColors = theme.custom;
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final secondaryTextColor = isDarkMode ? colorScheme.onSurfaceVariant : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 10),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/FI_logo.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'DSV360',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: customColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      "Powered by",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "DSV Group",
                      style: TextStyle(
                        color: customColors.primary ?? colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),

                    //Text("Digital Synergy Venture Group", style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold ),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
