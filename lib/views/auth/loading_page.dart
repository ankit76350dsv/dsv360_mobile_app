import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/session_manager.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/widgets/dsv_loader.dart';
import 'package:dsv360/models/active_user.dart';
import 'package:dsv360/core/constants/active_user_repository.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
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
        await UserManager.instance.fetchUserProfile(user.id);
      }

      // Fetch access token
      await TokenManager.instance.getToken();

      if (mounted) {
        // 1. Invalidate all stale providers from the previous user session
        //    BEFORE setting the new user. This clears old data without
        //    wiping the new user that is about to be set.
        SessionManager.invalidateAllProviders(
          ProviderScope.containerOf(context, listen: false),
        );

        // 2. Set the new active user AFTER invalidation so that when
        //    DashboardPage's children (CheckIn tab, Leave tab, etc.) build,
        //    they read the correct user from activeUserRepositoryProvider.
        if (user != null) {
          final activeUser = ActiveUserModel.fromCatalystUser(user);
          ref.read(activeUserRepositoryProvider.notifier).setUser(activeUser);
        }

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
          SnackBar(content: Text('Failed to load user data.')),
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
        child: DsvLoader(),
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     CircularProgressIndicator(),
        //     SizedBox(height: 16),
        //     Text('Loading...', style: TextStyle(fontSize: 16)),
        //   ],
        // ),
      ),
    );
  }
}
