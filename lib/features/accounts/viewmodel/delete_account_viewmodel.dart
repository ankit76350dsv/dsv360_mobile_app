import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/features/accounts/repositories/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteAccountViewModelProvider = Provider<DeleteAccountViewModel>((ref) {
  return DeleteAccountViewModel(ref.read(deleteAccountRepositoryProvider));
});

class DeleteAccountViewModel {
  DeleteAccountViewModel(this._deleteRepository);

  final AccountRepository _deleteRepository;

  Future<void> deleteAccountWithFallback({
    required BuildContext context,
    required String rowId,
  }) async {
    try {
      await _deleteRepository.deleteAccount(rowId: rowId);
    } catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, 'Something went wrong. Plase try again');
    }
  }
}
