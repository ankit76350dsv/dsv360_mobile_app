import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/session_manager.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/models/active_user.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/welcome/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingPage extends ConsumerStatefulWidget {
  const LoadingPage({super.key});

  @override
  ConsumerState<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Fetch user details
      final user = await AuthManager.instance.fetchUser();

      if (user != null) {
        // Populate the Riverpod provider so People/Check-In/Leave tabs work.
        final activeUser = ActiveUserModel.fromCatalystUser(user);
        ref.read(activeUserRepositoryProvider.notifier).setUser(activeUser);

        await UserManager.instance.fetchUserProfile(user.id);
      }

      // Fetch access token
      await TokenManager.instance.getToken();

      if (mounted) {
        // Invalidate all cached providers NOW — user is valid, DashboardPage
        // is not yet mounted so no active listeners → no immediate re-fetch.
        // This guarantees every screen loads fresh data for the new user.
        SessionManager.invalidateAllProviders(
          ProviderScope.containerOf(context, listen: false),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
        // Navigate back to WelcomePage on critical failure
         Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomePage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
