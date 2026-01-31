import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Image.asset('assets/images/FI_logo.png', width: 150, height: 150),
              const SizedBox(height: 24),
              // Welcome Text
              const Text(
                'Welcome to DSV360',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2857A4), // Primary Blue
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Manage your projects, tasks, and issues all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(flex: 3),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await AppInitManager.instance.catalystApp.login();
                    // Fetch user details after successful login
                    final user = await AuthManager.instance.fetchUser();
                    
                    if (user != null) {
                       await UserManager.instance.fetchUserProfile(user.id);
                    }
                    
                    // Fetch access token
                    await TokenManager.instance.getToken();

                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2857A4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
