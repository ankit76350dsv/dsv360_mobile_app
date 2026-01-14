import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  
  late CurrentUser _currentUser;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _currentUser = CurrentUser(
      id: 'user_001',
      name: 'John Doe',
      email: 'john@example.com',
      // role: UserRole.admin, // Change to UserRole.user for regular user
      role: UserRole.user,
    );
  }

  CurrentUser get currentUser => _currentUser;

  bool get isAdmin => _currentUser.isAdmin;
  bool get isUser => _currentUser.isUser;

  // Method to switch user role (for testing/admin panel)
  void switchRole(UserRole role) {
    _currentUser = _currentUser.copyWith(role: role);
    notifyListeners();
  }

  // Method to set current user
  void setUser(CurrentUser user) {
    _currentUser = user;
    notifyListeners();
  }

  // Method to login (mock implementation)
  Future<bool> login(String email, String password) async {
    // TODO: Implement actual login with backend
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // Method to logout
  void logout() {
    _currentUser = CurrentUser(
      id: '',
      name: '',
      email: '',
      role: UserRole.user,
    );
    notifyListeners();
  }
}

