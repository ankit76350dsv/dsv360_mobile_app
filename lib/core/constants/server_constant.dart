import 'package:dsv360/core/constants/environment.dart';

class ServerConstant {
  static String serverURL = ENVIRONMENT.environment == "DEVELOPMENT"
      ? 'https://project-management-60040289923.development.catalystserverless.in'
      : '';
}
