import 'package:dsv360/core/constants/environment.dart';

class ServerConstant {
  static String serverURL = ENVIRONMENT.environment == "DEVELOPMENT"
      ? ''
      : '';
}
