import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteAccountViewModelProvider = Provider<DeleteAccountViewModel>((ref) {
  return DeleteAccountViewModel();
});

class DeleteAccountViewModel {
  Future<void> deleteAccountWithFallback({
    required BuildContext context,
    required String rowId,
  }) async {
    try {
      await ApiClient.instance.delete(
        'time_entry_management_application_function/org/$rowId',
      );

      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
