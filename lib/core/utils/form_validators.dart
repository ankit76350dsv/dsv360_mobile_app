import '../constants/app_strings.dart';

class FormValidators {
  // Validate Name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    if (value.trim().length < 2) {
      return AppStrings.nameTooShort;
    }
    return null;
  }

  // Validate Email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired;
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.emailInvalid;
    }
    
    return null;
  }

  // Validate Message
  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.messageRequired;
    }
    if (value.trim().length < 10) {
      return AppStrings.messageTooShort;
    }
    return null;
  }
}
