# Dashboard & Project Page Show Previous User's Data After Logout/Login

**Date:** 12 March 2026  
**Severity:** Critical — wrong user sees another user's data

---

## The Problem

1. Login with **Admin account** → Dashboard shows correct stats (Total Employees, Total Projects, Completed Projects, Total Issues).
2. Logout → Login with **Employee account**.
3. Dashboard **still shows the Admin's data** — counts, projects, charts are all from the previous session.
4. The data never refreshes to reflect the new (employee) user.

---

## Root Cause

The app has **two independent caching layers**, and logout was only clearing **one** of them:

### Layer 1: Singleton caches (previously cleared ✅)

| Singleton | What it caches |
|---|---|
| `TokenManager` | OAuth access token + expiry timestamp |
| `UserManager` | `UserProfileModel` (name, avatar URL, etc.) |
| `AuthManager` | `ZCatalystUser` (userId, orgId, role, etc.) |
| Flutter `imageCache` | Network images (profile photos) |

These were already being cleared on logout (fixed in earlier session).

### Layer 2: Riverpod providers (NEVER cleared ❌ — THIS was the bug)

| Provider | What it caches | File |
|---|---|---|
| `dashboardDataProvider` | userCnt, projectCnt, completedProjectCnt, issueCnt, yearTaskData | `providers/dashboard_provider.dart` |
| `taskStatusDataProvider` | Open / In-Progress / Closed task counts | `providers/dashboard_provider.dart` |
| `projectAnalyticsDataProvider` | Monthly project analytics | `providers/dashboard_provider.dart` |
| `selectedYearProvider` | Selected year in pie chart picker | `providers/dashboard_provider.dart` |
| `selectedProjectYearProvider` | Selected year in bar chart picker | `providers/dashboard_provider.dart` |
| `projectListProvider` | List of all projects + task counts | `providers/project_provider.dart` |
| `issueListProvider` | List of all issues | `providers/issue_provider.dart` |
| `employeeListProvider` | List of all employees | `providers/employee_provider.dart` |
| `currentUserIdProvider` | Current user's ID | `providers/task_provider.dart` |
| `timerStatusProvider` | Timer running status | `providers/time_entry_provider.dart` |
| `activeUserRepositoryProvider` | Active user model | `repositories/active_user_repository.dart` |
| `organizationListRepositoryProvider` | Organization list | `repositories/organization_repository.dart` |
| `accountsListRepositoryProvider` | Accounts list | `repositories/accounts_list_repository.dart` |
| `feedbackRepositoryProvider` | Feedback list | `repositories/feedback_repository.dart` |
| `leaveDetailsListRepositoryProvider` | Leave details | `repositories/leaves_repository.dart` |
| `leaveCalendarRepositoryProvider` | Leave calendar events | `repositories/leaves_repository.dart` |
| `usersRepositoryProvider` | Users list | `repositories/users_repository.dart` |
| `holidayRepositoryProvider` | Holidays list | `repositories/holiday_repository.dart` |
| `userStatusRepositoryProvider` | Check-in status | `repositories/user_check_in_status_repository.dart` |
| `allDSVBadgesListRepositoryProvider` | Badges list | `repositories/all_badges_list.dart` |
| `clientContactsListRepositoryProvider` | Client contacts | `repositories/client_contacts_repository.dart` |
| + all `StateProvider`s | Search queries, selected filters | various |

**Why?** Most of these providers are **NOT `autoDispose`** — once a `FutureProvider` resolves, Riverpod keeps the resolved value forever within the `ProviderScope`. When a new user logs in, `DashboardPage` calls `ref.watch(dashboardDataProvider)` which **already has the old admin's data cached** — it returns immediately without re-fetching.

### Why the StatGrid showed stale data specifically

```
DashboardPage.build()
  └─ ref.watch(dashboardDataProvider)    ← returns CACHED old data instantly
       └─ StatGrid(
            userCnt: dashboard.userCnt,      ← old admin's count
            projectCnt: dashboard.projectCnt, ← old admin's count
            ...
          )
```

The provider never re-fetched because nothing invalidated it.

---

## Data Flow (showing where cache persists)

```
[ User taps Login ]
        │
        ▼
  LoadingPage._fetchUserData()
        │
        ├── AuthManager.fetchUser()        ← fetches NEW user   ✅
        ├── UserManager.fetchUserProfile() ← fetches NEW profile ✅
        └── TokenManager.getToken()        ← fetches NEW token   ✅
        │
        ▼
  Navigator → DashboardPage
        │
        ├── ref.watch(dashboardDataProvider)
        │       └── CACHED from old session! ❌  (never invalidated)
        │
        └── StatGrid shows OLD counts ❌
```

---

## Fix Applied

### New file: `lib/core/constants/session_manager.dart`

A centralized `SessionManager.logout(context)` that clears **everything** in one call:

```dart
class SessionManager {
  static Future<void> logout(BuildContext context) async {
    // 1. Catalyst SDK logout
    await AppInitManager.instance.catalystApp.logout();

    // 2. Clear singletons
    TokenManager.instance.clearToken();
    UserManager.instance.clear();
    AuthManager.instance.currentUser = null;

    // 3. Flush image cache
    PaintingBinding.instance.imageCache.clear();

    // 4. Invalidate ALL Riverpod providers
    final container = ProviderScope.containerOf(context, listen: false);
    _invalidateAllProviders(container);   // ← 20+ providers invalidated
  }
}
```

### Files changed

| File | Change |
|---|---|
| `lib/core/constants/session_manager.dart` | **NEW** — centralized logout handler |
| `lib/views/dashboard/AppDrawer.dart` | Logout now calls `SessionManager.logout(context)` |
| `lib/views/profile/profile_page.dart` | Logout now calls `SessionManager.logout(context)` |
| `lib/core/network/dio_client.dart` | `_forceLogout()` now also invalidates all providers |

### Before vs After

**Before (broken):**
```dart
// AppDrawer logout
await catalystApp.logout();
TokenManager.instance.clearToken();
UserManager.instance.clear();
AuthManager.instance.currentUser = null;
PaintingBinding.instance.imageCache.clear();
// ❌ Riverpod providers still hold old data!
```

**After (fixed):**
```dart
// AppDrawer logout — single call clears EVERYTHING
await SessionManager.logout(context);
// ✅ Singletons cleared
// ✅ Image cache cleared
// ✅ All 20+ Riverpod providers invalidated
// Next login → providers re-fetch for the new user
```

---

## How `container.invalidate()` works

| Condition | What `invalidate()` does |
|---|---|
| Provider has **no** active listeners | Marks it as stale — re-fetches lazily on next `watch`. ✅ |
| Provider has **active** listeners | Triggers an **immediate** re-fetch right now. ❌ |

---

## ❌ Update — 12 March 2026: First Fix Caused "Something Went Wrong" on Login

### New Symptom
After the first fix, logging out then back in showed **"something went wrong"** on the dashboard. Pulling to refresh fixed it.

### Why It Happened

The first fix called `_invalidateAllProviders(container)` **synchronously inside `SessionManager.logout()`**, AFTER clearing `AuthManager.instance.currentUser = null`. At that moment `DashboardPage` was still mounted (the drawer was open on top of it), so `dashboardDataProvider` had active listeners. Result: immediate re-fetch with a null user → `Exception('User not logged in')` → `AsyncError` state. That error persisted into the next login.

```
AuthManager.instance.currentUser = null        ← cleared
_invalidateAllProviders(container)             ← immediate re-fetch triggered
  └── dashboardDataProvider body:
        final user = AuthManager.instance.currentUser; // null!
        throw Exception('User not logged in');          // AsyncError ❌
// This error persists → new user logs in → "something went wrong"
// Pull to refresh → re-invalidates with valid user → works ✅
```

### ✅ Fix Applied (v2)

Defer `_invalidateAllProviders()` to **after the next rendered frame** using `WidgetsBinding.instance.addPostFrameCallback`. By then the caller has navigated to `WelcomePage` and `DashboardPage` is unmounted — providers have no active listeners, so `invalidate()` just marks them stale without triggering any re-fetch.

```dart
// session_manager.dart
static Future<void> logout(BuildContext context) async {
  // Capture container FIRST — before any async work or state changes.
  final container = ProviderScope.containerOf(context, listen: false);

  await AppInitManager.instance.catalystApp.logout();
  TokenManager.instance.clearToken();
  UserManager.instance.clear();
  AuthManager.instance.currentUser = null;
  PaintingBinding.instance.imageCache.clear();

  // DEFERRED: DashboardPage is unmounted by the time this runs.
  // No active listeners → no immediate re-fetch → no AsyncError. ✅
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _invalidateAllProviders(container);
  });
}
```

The same fix was applied to `ApiClient._forceLogout()` in `dio_client.dart`.

---

## How to verify

1. Login with Admin → note dashboard stats (e.g., Total Employees = 50).
2. Logout from drawer.
3. Login with Employee account.
4. Dashboard should show a **loading spinner**, then fresh employee data — **no "something went wrong", no manual refresh needed**.
5. Navigate to Projects → employee's projects only (not admin's).
6. Repeat from Profile page logout — same behavior.

