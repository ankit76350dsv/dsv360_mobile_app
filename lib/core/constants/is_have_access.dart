import 'package:dsv360/core/constants/auth_manager.dart';

class IsHaveAccess {
  IsHaveAccess._internal();
  static final IsHaveAccess _instance = IsHaveAccess._internal();
  static IsHaveAccess get instance => _instance;

  // Check if the current user has admin access
  bool get isAdmin {
    final user = AuthManager.instance.currentUser;
    // Check if role name is 'Admin' (case-insensitive just to be safe, though usage suggests exact match might be needed)
    // User requested: "if the role name is not admin" -> show limited. "if the role is admin" -> show all.
    // Assuming 'Admin' is the role name based on typical setups.
    return user?.role?.name == 'Admin';
  }

  // Check if the current user has manager access
  bool get isManager {
    final user = AuthManager.instance.currentUser;
    // Safely check if role name contains "manager" (case-insensitive)
    return user?.role?.name.toLowerCase().contains("manager") ?? false;
  }
}
