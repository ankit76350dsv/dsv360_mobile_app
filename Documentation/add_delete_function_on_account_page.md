# Delete Account Fix (What Was Actually Implemented)

This document explains the exact fix now applied to make the delete button work when backend returns 404 on the first route.

## Issue you were facing

Error:

- `Dio DELETE request failed ... status code 404`

Meaning:

- The app is calling a valid server path format, but that endpoint is not available in your current deployed backend.

## Exact code fix applied

File updated:

- `lib/features/accounts/view/pages/accounts_screen.dart`

Inside `_AccountsCardState`, I added a fallback delete flow:

1. Try primary route:
- `DELETE time_entry_management_application_function/clientOrg/{rowId}`

2. If 404, try legacy account route:
- `POST time_entry_management_application_function/deleteClient/{rowId}`

3. If still 404, try generic legacy route used in project module style:
- `DELETE time_entry_management_application_function/delete/{rowId}`

If any attempt succeeds, delete is treated as success.
If all attempts fail, error snackbar is shown.

## Helper methods added

Two helpers were added in the same class:

```dart
bool _is404Error(Object error) {
  return error.toString().contains('404');
}

Future<void> _deleteAccountWithFallback(String rowId) async {
  try {
    await ApiClient.instance.delete(
      'time_entry_management_application_function/clientOrg/$rowId',
    );
    return;
  } catch (e) {
    if (!_is404Error(e)) rethrow;
  }

  try {
    await ApiClient.instance.post(
      'time_entry_management_application_function/deleteClient/$rowId',
    );
    return;
  } catch (e) {
    if (!_is404Error(e)) rethrow;
  }

  await ApiClient.instance.delete(
    'time_entry_management_application_function/delete/$rowId',
  );
}
```

## Warning dialog integration (unchanged UI, fixed behavior)

`showWarningDialogueBox` is still used.
Only the primary button action changed to call fallback delete:

```dart
await _deleteAccountWithFallback(widget.account.rowId);
```

Then:

1. Pop dialog with success.
2. Invalidate `accountsListRepositoryProvider`.
3. Show `Account deleted successfully` snackbar.

On error:

1. Pop dialog with failure.
2. Show error snackbar with exception message.

## Why this fix is correct for your project

Based on your existing account API design:

1. Add and update already use legacy fallback (`createClient`, `updateClient`) in `add_edit_accounts.dart`.
2. So delete route mismatch across environments is expected.
3. Fallback routing is the safest production approach without breaking one environment while fixing another.

## How to verify now

1. Open Accounts page.
2. Tap delete icon on any account.
3. Confirm in warning dialog.
4. Expect account removed and success snackbar.

If it still fails, snackbar will show final backend error after all 3 route attempts.

## Final endpoint order now used in app

1. `DELETE time_entry_management_application_function/clientOrg/{rowId}`
2. `POST time_entry_management_application_function/deleteClient/{rowId}`
3. `DELETE time_entry_management_application_function/delete/{rowId}`
