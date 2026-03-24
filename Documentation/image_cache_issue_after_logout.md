# User Profile Image Cache Issue — After Logout & Re-login

> **Symptom:** After logging out and logging in with a different account, all app data updates correctly (name, role, etc.) but the **profile image still shows the previous user's photo**. It is stuck — neither loading the new account's image nor clearing the old one. Only a full hot restart fixes it.

---

## How Profile Images Are Currently Loaded

There are **3 places** in the app that display the user profile image. All 3 read directly from `UserManager.instance.userProfile` in memory and use `NetworkImage(url)` — Flutter's built-in image widget with its own internal HTTP image cache.

| Location | File | Variable used |
|---|---|---|
| Dashboard app bar | `lib/views/dashboard/dashboard_page.dart` line 96 | `userProfile.profileLink` |
| Drawer profile card | `lib/views/dashboard/AppDrawer.dart` line 454 | `userProfile.profileLink` |
| Profile page avatar | `lib/views/profile/profile_page.dart` line 87 | `userProfile?.profileLink` |
| Profile page cover | `lib/views/profile/profile_page.dart` line 51 | `userProfile?.coverLink` |

All use `NetworkImage(url)` which caches images by URL key in Flutter's `PaintingBinding.instance.imageCache`.

---

## How User Data Is Loaded on Login

**File:** `lib/views/auth/loading_page.dart`  
**Class:** `LoadingPage` → `_fetchUserData()`

```dart
final user   = await AuthManager.instance.fetchUser();
// stores: AuthManager.instance.currentUser = ZCatalystUser

await UserManager.instance.fetchUserProfile(user.id);
// stores: UserManager.instance.userProfile = UserProfileModel
// userProfile.profileLink = the image URL of the NEW user
```

- `UserManager.instance.userProfile.profileLink` is set to the new user's image URL.
- `UserManager.instance.userProfile.coverLink` is set to the new user's cover URL.
- This storage update works correctly — the URL string changes.

---

## What Happens on Logout

**File:** `lib/views/dashboard/AppDrawer.dart` — Logout button `onTap`

```dart
await AppInitManager.instance.catalystApp.logout();  // Catalyst SDK logout
TokenManager.instance.clearToken();                  // ✅ token is cleared

navigator.pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => const WelcomePage()),
  (route) => false,
);
```

**File:** `lib/views/profile/profile_page.dart` — Logout button

```dart
await AppInitManager.instance.catalystApp.logout();
Navigator.of(context).pushAndRemoveUntil(...WelcomePage...);
// ❌ TokenManager.clearToken() is NOT called here
// ❌ UserManager.clear() is NOT called here
```

**What is missing in both logout paths:**
- `UserManager.instance.clear()` is **never called** → `userProfile` stays in memory with the old user's URLs
- `PaintingBinding.instance.imageCache.clear()` is **never called** → Flutter's image cache still holds the old user's downloaded image bytes mapped to the old URL
- `AuthManager.instance.currentUser` is **never set to null** → old `ZCatalystUser` object stays in memory

---

## Root Cause 1 — `UserManager.userProfile` is never cleared on logout

**File:** `lib/core/constants/user_manager.dart`  
**Field:** `UserProfileModel? userProfile`

`UserManager` has a `clear()` method:
```dart
void clear() {
  userProfile = null;
}
```

But **`UserManager.instance.clear()` is never called anywhere in the logout flow**. The old `userProfile` object (with `profileLink` pointing to the previous user's photo URL) stays in memory.

When the new user logs in and `fetchUserProfile(newUserId)` is called, `userProfile` is replaced with the new user's data. This part works. The problem is what happens with Flutter's image cache (see Root Cause 2).

---

## Root Cause 2 — Flutter's `imageCache` retains the old image bytes by URL

**Widget used:** `NetworkImage(userProfile.profileLink)`

Flutter's `NetworkImage` caches downloaded image bytes internally in `PaintingBinding.instance.imageCache`, keyed by the **URL string**.

**Scenario — same URL, different user:**

This is the most common failure case:

1. User A logs in → `profileLink = "https://catalyst.../photo.jpg?id=A"`
2. Flutter downloads the image and caches it under key `"https://catalyst.../photo.jpg?id=A"`.
3. User A logs out → image cache is NOT cleared.
4. User B logs in → `profileLink = "https://catalyst.../photo.jpg?id=B"` (different URL) → new image loads correctly **if the URL is different**.
5. BUT if both users share a similar CDN structure and the URL happens to be the **same or collides**, the old cached bytes are returned immediately without re-fetching.

**Scenario — URL points to expired/inaccessible resource:**

Even when the URL changes between users, the old `NetworkImage` widget that was already built and rendered holds a reference to the image stream. Until the widget tree is rebuilt with the new URL and the old image evicted, the previous image may linger visually.

**Scenario — `userProfile` not yet updated but widget already rendered:**

If `dashboard_page.dart` reads `UserManager.instance.userProfile` at build time (not via a reactive provider), and `userProfile` is still the old object when the widget rebuilds, it renders the old image URL — regardless of cache.

---

## Root Cause 3 — `dashboard_page.dart` reads `userProfile` non-reactively

**File:** `lib/views/dashboard/dashboard_page.dart` line 33

```dart
final userProfile = UserManager.instance.userProfile;
```

This is a **synchronous read at build time** — it is not reactive (no `ref.watch`, no `setState`, no `StreamBuilder`). So:

- If the widget is already on screen and `userProfile` is replaced in memory, the widget does **not automatically rebuild** to show the new image.
- The old image URL stays in the `backgroundImage` of the `CircleAvatar` until the widget is fully disposed and rebuilt from scratch (which is what hot restart achieves).

Same issue exists in `AppDrawer.profileCardUi()`:
```dart
final userProfile = UserManager.instance.userProfile;
// read once, non-reactive
```

---

## Root Cause 4 — Profile page logout does not clear token

**File:** `lib/views/profile/profile_page.dart`

The logout button calls:
```dart
await AppInitManager.instance.catalystApp.logout();
Navigator.of(context).pushAndRemoveUntil(...WelcomePage...);
```

It does **not** call:
- `TokenManager.instance.clearToken()` ❌
- `UserManager.instance.clear()` ❌
- `AuthManager.instance.currentUser = null` ❌

So after logging out from the profile page, the in-memory state (token + user + profile) is completely stale. When the next user logs in, `fetchUserProfile` may even fail because the token is from the previous session.

---

## Root Cause 5 — No `imageCache.clear()` or `imageCache.evict()` on logout

Flutter provides:
```dart
PaintingBinding.instance.imageCache.clear();       // evict all cached images
PaintingBinding.instance.imageCache.evict(key);    // evict one specific image
```

Neither is called anywhere in the logout flow. Old downloaded photo bytes stay in RAM.

---

## How to Confirm If This Bug Still Exists

1. Log in as User A — note the profile photo shown in the app bar and drawer.
2. Log out using the drawer logout button.
3. Log in as User B (a different account with a different profile photo).
4. Check the app bar and drawer — if User A's photo is still showing, the bug is active.
5. Navigate to the Profile page — check if the cover image and avatar image belong to User B.

If **step 4 shows User A's photo**, the bug exists.  
If **step 4 shows User B's photo**, the bug is fixed.

---

## Why Hot Restart Fixes It

| What hot restart does | Why it helps |
|---|---|
| Clears all Dart memory | `UserManager.userProfile` → `null` |
| Clears Flutter image cache | All `NetworkImage` cached bytes are evicted |
| Re-runs `main()` → `LoadingPage` | Fresh `fetchUserProfile()` is called for the current user |
| Widget tree is fully rebuilt | Dashboard and drawer read the new `userProfile` from scratch |

---

## Potential Solutions

### Solution A — Call `UserManager.instance.clear()` on logout (Minimum fix)

In both logout locations, add `UserManager.instance.clear()` before navigating to `WelcomePage`.

**Files to change:**
- `lib/views/dashboard/AppDrawer.dart` — after `TokenManager.instance.clearToken()`
- `lib/views/profile/profile_page.dart` — after `catalystApp.logout()`

Also add `AuthManager.instance.currentUser = null` in both places.

This ensures that `userProfile` and `currentUser` are `null` after logout, so the widget shows the fallback (icon/default avatar) instead of a stale image.

---

### Solution B — Clear Flutter's image cache on logout

After clearing `UserManager`, also clear the image cache:

```dart
PaintingBinding.instance.imageCache.clear();
```

This evicts all downloaded images from memory so that on next login the new user's image is re-fetched from the network.

**Files to change:**
- `lib/views/dashboard/AppDrawer.dart` — logout block
- `lib/views/profile/profile_page.dart` — logout button

---

### Solution C — Use `CachedNetworkImage` package instead of `NetworkImage`

The `cached_network_image` package provides:
- `CachedNetworkImageProvider` which has an `evictFromCache(url)` method per URL.
- On logout, call `CachedNetworkImageProvider(oldUrl).evict()` to remove only the previous user's image.

This is more targeted than clearing the entire Flutter image cache.

**Files to change:**
- `lib/views/dashboard/dashboard_page.dart` — replace `NetworkImage` with `CachedNetworkImageProvider`
- `lib/views/dashboard/AppDrawer.dart` — replace `NetworkImage`
- `lib/views/profile/profile_page.dart` — replace `NetworkImage`
- `pubspec.yaml` — add `cached_network_image` dependency

---

### Solution D — Make image widgets reactive to `UserManager` changes

Wrap the dashboard, drawer, and profile avatar widgets in a reactive mechanism (e.g. `ChangeNotifier`, `ValueNotifier`, or a Riverpod provider) that rebuilds when `userProfile` changes.

This ensures the widget always reads the latest `userProfile` rather than a stale snapshot captured at build time.

**Files to change:**
- `lib/core/constants/user_manager.dart` — extend `ChangeNotifier`, call `notifyListeners()` in `fetchUserProfile()` and `clear()`
- `lib/views/dashboard/dashboard_page.dart` — wrap avatar with `ListenableBuilder`
- `lib/views/dashboard/AppDrawer.dart` — wrap `profileCardUi` with `ListenableBuilder`

---

## Summary — Files to Change

| File | What to fix |
|---|---|
| `lib/views/dashboard/AppDrawer.dart` | Add `UserManager.instance.clear()`, `AuthManager.instance.currentUser = null`, `PaintingBinding.instance.imageCache.clear()` in logout block |
| `lib/views/profile/profile_page.dart` | Add same 3 cleanup calls + `TokenManager.instance.clearToken()` in logout button |
| `lib/core/constants/user_manager.dart` | Optionally make it a `ChangeNotifier` for reactivity |
| `lib/views/dashboard/dashboard_page.dart` | Optionally make avatar reactive |

---

## Files That Do NOT Need Changing

| File | Reason |
|---|---|
| `lib/views/auth/loading_page.dart` | Already calls `fetchUserProfile()` correctly on every login |
| `lib/views/splash/splash_screen.dart` | Already calls `fetchUserProfile()` correctly on app start |
| `lib/core/constants/token_manager.dart` | Already has `clearToken()` — just needs to be called in both logout paths |
| `lib/repositories/*` | No changes needed — data layer is fine |
| `lib/models/user_profile_model.dart` | Model is correct — `profileLink` and `coverLink` are parsed properly |
