import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/accounts/repositories/accounts_list_repository.dart';
import 'package:dsv360/features/client/repositories/client_contacts_repository.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientContactFormViewModelProvider =
    Provider<ClientContactFormViewModel>((ref) {
  return ClientContactFormViewModel(ref);
});

class ClientContactFormViewModel {
  final Ref ref;

  ClientContactFormViewModel(this.ref);

  Future<void> _createClientContact(Map<String, dynamic> body) async {
    await ApiClient.instance.post(
      'time_entry_management_application_function/addContact',
      data: body,
    );
  }

  Future<void> _updateClientContact({
    required Map<String, dynamic> body,
    required String rowId,
  }) async {
    await ApiClient.instance.put(
      'time_entry_management_application_function/contact/$rowId',
      data: body,
    );
  }

  Future<void> submitClientContact({
    required BuildContext context,
    required bool isEditing,
    required String bottomTwoButtonsLoadingKey,
    required String? organization,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String? rowId,
  }) async {
    if (organization == null || organization.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select organization')),
      );
      return;
    }

    ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state =
        true;

    final accounts = ref.read(accountsListRepositoryProvider).value;
    final activeUser = ref.read(activeUserRepositoryProvider);
    final userProfile = UserManager.instance.userProfile;

    String? orgId;
    if (accounts != null) {
      try {
        final account =
            accounts.firstWhere((dynamic a) => a.orgName == organization);
        orgId = account.rowId;
      } catch (_) {}
    }

    if (orgId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not determine OrgID for the selected organization.',
          ),
        ),
      );
      ref
          .read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier)
          .state = false;
      return;
    }

    final creatorId =
        activeUser?.creatorId?.toString() ?? userProfile?.creatorId ?? '';
    final userId = activeUser?.userId?.toString() ?? userProfile?.userId ?? '';

    if (creatorId.isEmpty || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Missing user session fields (CREATORID/UserID). Please re-login and try again.',
          ),
        ),
      );
      ref
          .read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier)
          .state = false;
      return;
    }

    final body = {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email_id': email.trim(),
      'org_name': organization,
      'org_id': orgId,
      'phone': phone.trim(),
      'status': 'true',
    };

    try {
      if (isEditing) {
        await _updateClientContact(body: body, rowId: rowId!);
      } else {
        await _createClientContact(body);
      }

      if (!context.mounted) return;

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Client contact updated successfully'
                : 'Client contact added successfully',
          ),
        ),
      );

      ref.invalidate(clientContactsListRepositoryProvider);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save client contact. Please try again.')),
      );
    } finally {
      ref
          .read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier)
          .state = false;
    }
  }
}
