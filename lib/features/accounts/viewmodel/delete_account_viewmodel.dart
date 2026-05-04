import 'package:dsv360/features/accounts/repositories/delete_account_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteAccountViewModelProvider = Provider<DeleteAccountViewModel>((ref) {
  return DeleteAccountViewModel(ref.read(deleteAccountRepositoryProvider));
});

class DeleteAccountViewModel {
  DeleteAccountViewModel(this._deleteRepository);

  final DeleteAccountRepository _deleteRepository;

  Future<void> deleteAccountWithFallback({
    required BuildContext context,
    required String rowId,
  }) async {
    try {
      await _deleteRepository.deleteAccount(rowId: rowId);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
