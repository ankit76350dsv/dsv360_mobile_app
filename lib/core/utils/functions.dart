import 'package:dsv360/models/active_user.dart';

class Functions {
  static bool isAdmin(ActiveUserModel user) {
    return user.roleName == 'Admin';
    // return true;
  }
}