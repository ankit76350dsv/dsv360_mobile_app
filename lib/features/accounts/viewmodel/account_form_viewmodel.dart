import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/features/accounts/viewmodel/accounts_list_viewmodel.dart';
import 'package:dsv360/features/accounts/repositories/account_repository.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountFormViewModelProvider = Provider<AccountFormViewModel>((ref) {
  return AccountFormViewModel(
    ref: ref,
    createRepository: ref.read(createAccountRepositoryProvider),
    updateRepository: ref.read(updateAccountRepositoryProvider),
  );
});

class AccountFormViewModel {
  AccountFormViewModel({
    required this.ref,
    required this.createRepository,
    required this.updateRepository,
  });

  final Ref ref;
  final AccountRepository createRepository;
  final AccountRepository updateRepository;

  Map<String, dynamic> buildRequestBody({
    required String email,
    required String accountName,
    required String? orgType,
    required String? orgStatus,
    required String website,
  }) {
    return {
      "Email": email.trim(),
      "Org_Img": "",
      "Org_Name": accountName,
      "Org_Type": orgType.toString(),
      "Status": orgStatus,
      "Website": website,
    };
  }

  Future<void> submitAccount({
    required BuildContext context,
    required bool isEditing,
    required String bottomTwoButtonsLoadingKey,
    required String? orgStatus,
    required String? orgType,
    required String? rowId,
    required Map<String, dynamic> body,
  }) async {
    if (orgStatus == null || orgStatus.isEmpty) {
     
      showErrorSnackBar(context, 'Please select organization status');
      return;
    }

    if (orgType == null || orgType.isEmpty) {
      
      showErrorSnackBar(context, 'Please select organization type');
      return;
    }

    ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state = true;

    try {
      if (isEditing) {
        await updateRepository.updateAccount(rowId: rowId!, body: body);
      } else {
        await createRepository.createAccount(body);
      }

      if (!context.mounted) return;
      Navigator.pop(context, true);

      
      showSuccessSnackBar(context, isEditing ? 'Account updated successfully' : 'Account added successfully');

      ref.invalidate(accountsListRepositoryProvider);
    } catch (e) {
      debugPrint('❌ Failed to submit user: $e');

      if (!context.mounted) return;
      
      showErrorSnackBar(context, 'Failed to save account');
    } finally {
      ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state = false;
    }
  }
}
