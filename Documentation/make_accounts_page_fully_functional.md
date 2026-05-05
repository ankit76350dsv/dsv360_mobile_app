## Goal

Make the **Accounts** page fully functional (Add, Edit, Delete) while:

- Re‑using the existing components and theme system already used in the app.
- Calling the correct backend APIs.
- Keeping the code patterns consistent with **Projects**, **Issues**, and **Tasks** screens.

This document assumes you know almost nothing about the feature. Follow the steps in order and copy–paste the code where indicated.

---

## 1. Files involved in the Accounts feature

You will mainly touch these files:

1. `lib/models/accounts.dart`  
	 - Defines the `Account` model (fields like `Org_Name`, `Status`, `Email`, `ROWID`, etc.).

2. `lib/repositories/accounts_list_repository.dart`  
	 - Riverpod `AsyncNotifier` that fetches the accounts list from the backend using:  
		 `GET time_entry_management_application_function/clientOrg`
	 - Exposes `accountsListRepositoryProvider` (the source of truth for the Accounts list).
	 - Exposes `accountsSearchQueryProvider` (text used to filter/search accounts).

3. `lib/views/accounts/accounts_page.dart`  
	 - The main **Accounts list screen**.
	 - Shows the list of accounts using `AccountsListRepository`.
	 - Has a **Floating Action Button (FAB)** that should open the Add Account screen.
	 - Contains `AccountsCard`, which shows each account with **Edit** and **Delete** buttons.

4. `lib/views/accounts/add_edit_accounts_page.dart`  
	 - The **Add / Edit Account** form.
	 - Uses shared components like `CustomInputField`, `CustomDropDownField`, and `BottomTwoButtons`.
	 - Should call the proper **create / update** APIs.

5. `lib/views/dashboard/AppDrawer.dart`  
	 - The app drawer already contains an **Accounts** menu item that opens `AccountsPage` for admin users.

You do **not** need to create new files to make Add / Edit / Delete work. You will only change code inside the files listed above.

---

## 2. Backend APIs used for Accounts

From `Documentation/full_project_analysis.md`:

- `GET  time_entry_management_application_function/clientOrg`  → fetch all client organizations (accounts).
- `POST time_entry_management_application_function/clientOrg`  → create a new client organization.
- `PUT  time_entry_management_application_function/clientOrg/{id}`  → update an existing client organization.

> Note: The **delete** endpoint is not explicitly listed in the docs. Most of the app follows a REST pattern like:
>
> - `tion_function/issue/{id}`
> - `DELETE time_entry_management_application_function/tasks/{rowId}`
>DELETE time_entry_management_applica
> For Accounts we will follow the same REST pattern and use:  
> `DELETE time_entry_management_application_function/clientOrg/{rowId}`  
> If your backend differs, only the **URL string** needs to change; the rest of this document still applies.

All of these calls are made using the shared `ApiClient` in `lib/core/network/dio_client.dart`.

---

## 3. Make the FAB actually open the Add Account screen

**File:** `lib/views/accounts/accounts_page.dart`

1. Open the `AccountsPage` widget and locate the `floatingActionButton` inside the `Scaffold`.

2. You will see code like this (simplified):

```dart
floatingActionButton: connectivityStatus.when(
	data: (results) {
		if (results.contains(ConnectivityResult.none)) {
			return null; // FAB hidden when no internet
		}

		return FloatingActionButton(
			shape: const CircleBorder(),
			backgroundColor: customColors.primary,
			onPressed: () {
				// do nothing for the moment

				// Navigator.push(
				//   context,
				//   MaterialPageRoute(
				//     builder: (_) => AddEditAccountsPage(account: null),
				//   ),
				// );
			},
			child: Icon(Icons.add, size: 28, color: Colors.white,),
		);
	},
	// ...
),
```

3. Replace the **entire** `onPressed` body with this implementation:

```dart
onPressed: () async {
	// Open the Add Account screen.
	// Passing `account: null` means "create new" mode.
	final bool? result = await Navigator.push<bool>(
		context,
		MaterialPageRoute(
			builder: (_) => const AddEditAccountsPage(account: null),
		),
	);

	// If the Add screen reports success, refresh the list.
	if (result == true && mounted) {
		ref.refresh(accountsListRepositoryProvider);
	}
},
```

4. Why this works:

- `AddEditAccountsPage` already calls `Navigator.pop(context, true);` on success.
- The `result == true` check tells us an account was successfully added.
- `ref.refresh(accountsListRepositoryProvider);` uses the existing Riverpod notifier to reload the list from the backend.

The FAB now **opens the Add screen and refreshes the list** when a new account is saved.

---

## 4. Fix Add / Edit API calls in `AddEditAccountsPage`

**File:** `lib/views/accounts/add_edit_accounts_page.dart`

This screen already:

- Uses the correct shared widgets (`CustomInputField`, `CustomDropDownField`, `BottomTwoButtons`).
- Builds a request body via `_buildRequestBody()`.
- Shows success and error `SnackBar`s.
- Invalidates `accountsListRepositoryProvider` after a successful save.

You only need to make sure it calls the **correct** backend endpoints.

### 4.1. Verify imports

At the top of the file, make sure you have:

```dart
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/accounts.dart';
import 'package:dsv360/repositories/accounts_list_repository.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

These should already exist; do not remove them.

### 4.2. Keep `_buildRequestBody()` as the single source of truth

`_buildRequestBody()` is already correct and matches the API fields:

```dart
Map<String, dynamic> _buildRequestBody() {
	return {
		"Email": _emailController.text.trim(),
		"Org_Img": "",
		"Org_Name": _accountNameController.text.toString(),
		"Org_Type": _orgType.toString(),
		"Status": _orgStatus,
		"Website": _websiteController.text.toString(),
	};
}
```

Do **not** change this unless the backend field names change.

### 4.3. Update the submit button to use `clientOrg` endpoints

Scroll down to the `BottomTwoButtons` widget inside `build()` and find `button2Function`. You will see a `try` block that currently uses old `/server/...createClient` and `/server/...updateClient/...` URLs.

Replace the **entire** `try { ... }` block inside `button2Function` with this:

```dart
try {
	final body = _buildRequestBody();

	if (isEditing) {
		// UPDATE existing account
		await ApiClient.instance.put(
			'time_entry_management_application_function/clientOrg/${widget.account!.rowId}',
			data: body,
		);
	} else {
		// CREATE new account
		await ApiClient.instance.post(
			'time_entry_management_application_function/clientOrg',
			data: body,
		);
	}

	// Close this screen and tell the caller we succeeded.
	Navigator.pop(context, true);

	ScaffoldMessenger.of(context).showSnackBar(
		SnackBar(
			content: Text(
				isEditing
						? 'Account updated successfully'
						: 'Account added successfully',
			),
		),
	);

	// Force the accounts list to reload from the backend.
	ref.invalidate(accountsListRepositoryProvider);
} catch (e) {
	debugPrint('❌ Failed to submit account: $e');

	ScaffoldMessenger.of(context).showSnackBar(
		const SnackBar(
			content: Text('Failed to save account'),
		),
	);
}
```

Leave the surrounding validation and loading‑state code (`submitLoadingProvider`, `finally { ... }`) exactly as it already is.

Result:

- Add mode → `POST /clientOrg` with the body from `_buildRequestBody()`.
- Edit mode → `PUT /clientOrg/{ROWID}` with the same body.
- The list screen always sees fresh data because the provider is invalidated.

---

## 5. Wire up Delete Account (button + dialog + API)

Now we want the **Delete** button on each `AccountsCard` to:

1. Show a confirmation dialog that matches the app’s theme.
2. Call the backend delete API.
3. Refresh the list and show a success or error message.

### 5.1. Make sure `AccountsCard` calls `_showDeleteDialog`

**File:** `lib/views/accounts/accounts_page.dart`

Inside `_AccountsCardState.build`, find the delete `CustomCardButton`. It currently looks like this (simplified):

```dart
CustomCardButton(
	onTap: () {
		// do nothing for the moment

		// _showDeleteDialog(
		//   context,
		//   widget.account.orgName,
		// );
	},
	icon: Icons.delete,
	color: customColors.error,
),
```

Replace the `onTap` body with this:

```dart
onTap: () {
	_showDeleteDialog(context, widget.account.orgName);
},
```

This simply opens the confirmation dialog when the user taps the delete icon.

### 5.2. Implement `_showDeleteDialog` with API call and theming

Still in `AccountsCard` (same file), scroll down to the `_showDeleteDialog` method.

Replace the **entire** `_showDeleteDialog` method with the following implementation:

```dart
void _showDeleteDialog(BuildContext context, String orgName) {
	final customColors = Theme.of(context).custom;

	showDialog(
		context: context,
		barrierDismissible: false,
		builder: (dialogContext) {
			return AlertDialog(
				backgroundColor: customColors.cardBackground,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(12),
				),
				title: Text(
					'Delete Client',
					style: TextStyle(color: customColors.textPrimary),
				),
				content: Text(
					'Are you sure you want to delete "$orgName"?',
					style: TextStyle(color: customColors.textSecondary),
				),
				actions: [
					TextButton(
						onPressed: () {
							Navigator.pop(dialogContext); // close dialog
						},
						child: Text(
							'Cancel',
							style: TextStyle(color: customColors.primary),
						),
					),
					TextButton(
						onPressed: () async {
							// Capture messenger *before* popping the dialog
							final scaffoldMessenger = ScaffoldMessenger.of(context);
							Navigator.pop(dialogContext); // close dialog

							try {
								// Call backend DELETE endpoint for this account
								await ApiClient.instance.delete(
									'time_entry_management_application_function/clientOrg/${widget.account.rowId}',
								);

								// Refresh the accounts list
								ref.refresh(accountsListRepositoryProvider);

								if (mounted) {
									scaffoldMessenger.showSnackBar(
										SnackBar(
											content: Row(
												children: [
													const Icon(Icons.check_circle, color: Colors.white),
													const SizedBox(width: 12),
													Expanded(
														child: Text(
															'Client "$orgName" deleted successfully',
															style: const TextStyle(color: Colors.white),
														),
													),
												],
											),
											backgroundColor: customColors.primary,
											behavior: SnackBarBehavior.floating,
											duration: const Duration(seconds: 3),
										),
									);
								}
							} catch (e) {
								if (mounted) {
									scaffoldMessenger.showSnackBar(
										SnackBar(
											content: Row(
												children: [
													const Icon(Icons.error_outline, color: Colors.white),
													const SizedBox(width: 12),
													Expanded(
														child: Text(
															'Failed to delete client: $e',
															style: const TextStyle(color: Colors.white),
														),
													),
												],
											),
											backgroundColor: customColors.error,
											behavior: SnackBarBehavior.floating,
											duration: const Duration(seconds: 3),
										),
									);
								}
							}
						},
						style: TextButton.styleFrom(foregroundColor: customColors.error),
						child: const Text('Delete'),
					),
				],
			);
		},
	);
}
```

Key points:

- **Theme matching**: Uses `Theme.of(context).custom` just like other screens (e.g. Issues, Projects).
- **Behavior**:
	- *Cancel* closes the dialog only.
	- *Delete* calls the backend `DELETE` endpoint, refreshes the provider, and shows a `SnackBar`.

If your backend uses a slightly different delete URL, only change the string inside `ApiClient.instance.delete(...)`.

---

## 6. Confirm navigation from the App Drawer

**File:** `lib/views/dashboard/AppDrawer.dart`

There is already an Accounts entry that opens the Accounts page:

```dart
if (IsHaveAccess.instance.isAdmin)
	_DrawerItem(
		icon: Icons.apartment_outlined,
		label: 'Accounts',
		subLabel: 'Client organizations',
		onTap: () {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (_) => AccountsPage()),
			);
		},
	),
```

You do not need to change this. Just make sure you **did not remove** this code.

---

## 7. End‑to‑end flow check

After applying all instructions above, the complete flow is:

1. **Open Accounts** from the drawer (Admin users only).
2. The page uses `accountsListRepositoryProvider` to load data from  
	 `GET time_entry_management_application_function/clientOrg`.
3. **Search bar** filters accounts using `accountsSearchQueryProvider` (already implemented).
4. **Add (FAB)**:
	 - Checks connectivity via `connectivityStatusProvider`.
	 - Opens `AddEditAccountsPage(account: null)`.
	 - On save, calls `POST /clientOrg`, pops with `true`, and refreshes the list.
5. **Edit (pencil icon on card)**:
	 - Opens `AddEditAccountsPage(account: widget.account)`.
	 - On save, calls `PUT /clientOrg/{ROWID}`, pops with `true`, and refreshes the list.
6. **Delete (trash icon on card)**:
	 - Shows a themed confirmation dialog.
	 - On delete, calls `DELETE /clientOrg/{ROWID}`.
	 - Refreshes the list and shows a success or error `SnackBar`.

With these changes, the Accounts page will behave consistently with the Projects and Issues modules, using the same theming system and shared widgets.
