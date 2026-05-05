# Account Add/Edit API Fix Guide (Applied Solution)

## Problem summary

The account form was failing because API paths and methods were inconsistent.

Main issues:

1. Wrong URL style in some places (`/server/...`) produced bad final URLs.
2. Edit account was using `POST` where backend expects `PUT` for REST update.
3. If status/type were not selected, request body could send invalid values.
4. Some environments still use older route names (`createClient`, `updateClient`).

This guide documents the exact fix now applied in:

- `lib/views/accounts/add_edit_accounts_page.dart`

---

## Final working approach

### 1) Always use relative paths with `ApiClient`

Correct style:

- `time_entry_management_application_function/clientOrg`

Do not use:

- `/server/time_entry_management_application_function/clientOrg`

Reason:

- Base URL already ends with `/server/`.
- Adding `/server` again causes broken URL (`/server/server/...`).

---

### 2) Add account flow (Create)

Primary API used:

- `POST time_entry_management_application_function/clientOrg`

Fallback used only when primary returns 404:

- `POST time_entry_management_application_function/createClient`

Why fallback exists:

- Some backend deployments still expose old route names.

---

### 3) Edit account flow (Update)

Primary API used:

- `PUT time_entry_management_application_function/clientOrg/{rowId}`

Fallback used only when primary returns 404:

- `POST time_entry_management_application_function/updateClient/{rowId}`

Why this is correct:

- REST update should use `PUT`.
- Fallback keeps app working in legacy backend setups.

---

### 4) Required dropdown validation before API call

Before submission, the form now blocks request unless both are selected:

1. Organization Status
2. Organization Type

If missing, user gets clear snackbar messages.

This prevents invalid payload values and avoidable API failures.

---

## Exact code pattern now used

```dart
Future<void> _createAccount(Map<String, dynamic> body) async {
	try {
		await ApiClient.instance.post(
			'time_entry_management_application_function/clientOrg',
			data: body,
		);
	} catch (e) {
		if (!e.toString().contains('404')) rethrow;
		await ApiClient.instance.post(
			'time_entry_management_application_function/createClient',
			data: body,
		);
	}
}

Future<void> _updateAccount(Map<String, dynamic> body) async {
	try {
		await ApiClient.instance.put(
			'time_entry_management_application_function/clientOrg/${widget.account!.rowId}',
			data: body,
		);
	} catch (e) {
		if (!e.toString().contains('404')) rethrow;
		await ApiClient.instance.post(
			'time_entry_management_application_function/updateClient/${widget.account!.rowId}',
			data: body,
		);
	}
}
```

And submit button now calls:

- `_updateAccount(body)` in edit mode
- `_createAccount(body)` in add mode

---

## Verification checklist

Follow this after running app:

1. Open Add Account page.
2. Fill all fields, select status and type, submit.
3. Expect success snackbar and no 404.
4. Open existing account, edit data, submit.
5. Expect success snackbar and updated data after refresh.

Log URL should never contain `/server/server/`.

---

## If issue still appears

Check these quickly:

1. `ServerConstant.serverURL` must be valid and reachable.
2. Auth token/session must be active.
3. Backend deployment must expose either:
	 - `clientOrg` routes (preferred), or
	 - legacy `createClient`/`updateClient` routes (fallback).

---

## One-line conclusion

The fix is complete by using correct relative paths, correct update method (`PUT`), required dropdown validation, and safe legacy fallbacks for 404 route mismatch.

