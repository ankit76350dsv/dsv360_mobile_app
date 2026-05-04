import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/accounts/repositories/accounts_list_repository.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountFormViewModelProvider = Provider<AccountFormViewModel>((ref) {
  return AccountFormViewModel(ref);
});

class AccountFormViewModel {
  final Ref ref;

  AccountFormViewModel(this.ref);

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

  Future<void> createAccount(Map<String, dynamic> body) async {
    try {
      await ApiClient.instance.post(
        'time_entry_management_application_function/clientOrg',
        data: body,
      );
    } catch (e) {
      // Fallback kept for environments still wired to legacy route names.
      if (!e.toString().contains('404')) rethrow;
      await ApiClient.instance.post(
        'time_entry_management_application_function/createClient',
        data: body,
      );
    }
  }

  Future<void> updateAccount({
    required Map<String, dynamic> body,
    required String rowId,
  }) async {
    try {
      await ApiClient.instance.put(
        'time_entry_management_application_function/clientOrg/$rowId',
        data: body,
      );
    } catch (e) {
      // Fallback kept for environments still wired to legacy route names.
      if (!e.toString().contains('404')) rethrow;
      await ApiClient.instance.post(
        'time_entry_management_application_function/updateClient/$rowId',
        data: body,
      );
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select organization status'),
        ),
      );
      return;
    }

    if (orgType == null || orgType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select organization type'),
        ),
      );
      return;
    }

    ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state =
        true;

    try {
      if (isEditing) {
        await updateAccount(body: body, rowId: rowId!);
      } else {
        await createAccount(body);
      }

      Navigator.pop(context, true); // success

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Account updated successfully'
                : 'Account added successfully',
          ),
        ),
      );

      // throw current state and rebuild it from scratch
      ref.invalidate(accountsListRepositoryProvider);
    } catch (e) {
      debugPrint('❌ Failed to submit user: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save account'),
        ),
      );
    } finally {
      ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state =
          false;
    }
  }
}
