import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/accounts/viewmodel/accounts_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showDeleteDialoge({
	required BuildContext context,
	required WidgetRef ref,
	required String orgName,
	required String rowId,
	required Future<void> Function(String rowId) onDelete,
}) {
	showWarningDialogueBox<bool>(
		context: context,
		title: 'Delete Account',
		subtitle: 'Are you sure you want to delete Account "$orgName" ?',
		primaryText: 'DELETE',
		onPrimaryPressed: (dialogContext) async {
			try {
				await onDelete(rowId);

				if (!context.mounted) return;
				Navigator.of(dialogContext).pop(true);
				ref.invalidate(accountsListRepositoryProvider);
        showSuccessSnackBar(context, 'Account deleted successfully');
			} catch (e) {
				if (!context.mounted) return;
				Navigator.of(dialogContext).pop(false);

        showErrorSnackBar(context, 'Failed to delete account. Please try again.');
			}
		},
	).then((confirmed) {
		if (confirmed != true) {
			try {
				ref.invalidate(accountsListRepositoryProvider);
			} catch (e) {}
		}
	});
}
