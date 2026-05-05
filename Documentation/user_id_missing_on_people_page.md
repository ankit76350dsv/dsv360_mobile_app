# User ID Missing Exception on People Page

**Date:** 12 March 2026  
**File:** `lib/views/people/people_page.dart`  
**Widget:** `_CheckInTabState.build()`

---

## The Error

```
Exception: User ID is missing.
```

The error repeated multiple times in the console because Flutter re-builds widgets on each frame while the tab is visible.

---

## Root Cause

`activeUserRepositoryProvider` is a provider that reads from `ActiveUserRepository`. When the People page first opens, or when the provider hasn't resolved yet, `activeUser` is `null`. The code read:

```dart
final activeUser = ref.watch(activeUserRepositoryProvider);
final userId = activeUser?.userId ?? '';
if (userId.isEmpty) {
  throw Exception("User ID is missing.");  // ❌ throws during normal async loading
}
```

Throwing an exception inside `build()` is wrong — `activeUser` being null is not an error state; it is simply the initial/loading state before the data has arrived. Flutter's error handler catches the thrown exception and re-renders the error widget, which triggers another build, creating a repetitive error loop.

**Why other tabs don't have this problem:**  
`_AttendanceTabState.build()` (same file) handles the same scenario correctly:

```dart
if (userId.isEmpty) {
  return const Center(child: GlobalLoader(message: 'Loading user info...'));
}
```

---

## Fix Applied

Replaced the `throw` with a `GlobalLoader` return, matching the pattern used elsewhere in the file:

```dart
// Before (broken)
if (userId.isEmpty) {
  throw Exception("User ID is missing.");
}

// After (fixed)
if (userId.isEmpty) {
  return const GlobalLoader(message: 'Loading user info...');
}
```

**File changed:** [`lib/views/people/people_page.dart`](../lib/views/people/people_page.dart) — `_CheckInTabState.build()`.

---

## Why This Pattern Must Be Followed

| Scenario | Correct handling |
|---|---|
| Data not yet loaded (`null` / empty) | Return a loader widget |
| Data loaded but genuinely missing (auth bug) | Show an error widget with retry |
| Programmer logic error | Use `assert()` in debug only, never `throw` in `build()` |

Throwing inside `build()` is never correct for async data — the widget tree is rebuilt many times and the exception fires on every build until the data arrives.
