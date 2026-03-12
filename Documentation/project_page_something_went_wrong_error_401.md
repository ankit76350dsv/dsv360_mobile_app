# 401 Unauthorised Error — Projects Screen (Intermittent)

> **Symptom:** After login, or during normal app use, the Projects screen (and potentially other screens) suddenly shows  
> *"Error loading projects: Exception: Error fetching projects: Exception: Dio GET request failed: status code 401"*  
> The error disappears only after a **hot restart**.

---

## What a 401 means here

The Catalyst API is returning **HTTP 401 Unauthorized**, meaning the `Authorization` header the app sent with the request was **rejected by the server** — either the token is expired, missing, or invalid.

---

## Root Cause 1 — Token is cached forever in memory and never refreshed

**File:** `lib/core/constants/token_manager.dart`  
**Class:** `TokenManager`  
**Field:** `String? _accessToken`

```dart
Future<String?> getToken() async {
  if (_accessToken != null) {   // ← returns stale token immediately, no expiry check
    return _accessToken;
  }
  ...
}
```

- The first time `getToken()` is called it fetches a fresh token from the Catalyst SDK and stores it in `_accessToken`.
- **Every subsequent call returns the same cached string directly**, without ever checking whether it has expired.
- `clearToken()` sets `_accessToken = null`, but **nothing in the app calls `clearToken()` automatically** — it is never triggered on a 401 response.
- Zoho Catalyst OAuth access tokens typically **expire after 1 hour**.
- After ~1 hour the token is dead, but `_accessToken` still holds the old value, so every API call sends an expired token → server replies 401.
- A **hot restart** clears all Dart memory → `_accessToken` becomes `null` → next call fetches a fresh token → works again until the new token also expires.

---

## Root Cause 2 — No retry-on-401 interceptor in the HTTP client

**File:** `lib/core/network/dio_client.dart`  
**Class:** `ApiClient`

```dart
_dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await TokenManager.instance.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Zoho-oauthtoken $token';
      }
      return handler.next(options);
    },
  ),
);
```

- There is **only a request interceptor** — it injects the token before sending.
- There is **no response interceptor / error interceptor** that:
  - catches a 401 response,
  - clears the stale token,
  - fetches a new token, and
  - retries the original request.
- So when 401 arrives, Dio throws a `DioException`, the repository catches it and re-throws `Exception('Error fetching projects: ...')`, and the UI shows the error widget. The stale token stays in memory untouched.

---

## Root Cause 3 — `app.getAccessToken()` result is wrapped and re-cached, hiding SDK refresh

**File:** `lib/core/constants/token_manager.dart`  
**Method:** `_fetchTokenInternal()`

```dart
Future<String?> _fetchTokenInternal() async {
  final app = AppInitManager.instance.catalystApp;
  final token = await app.getAccessToken();   // Catalyst SDK call
  _accessToken = token;
  return token;
}
```

- The Catalyst SDK (`zcatalyst_sdk`) may be able to return a refreshed token when called again (using its internal refresh-token flow).
- However, because `TokenManager` **never calls `_fetchTokenInternal()` again** once `_accessToken != null`, the SDK's refresh capability is completely bypassed.
- The stale in-memory string is returned every time instead.

---

## Root Cause 4 — Dio's `validateStatus` treating 401 as a hard throw, not a catchable state

**File:** `lib/core/network/dio_client.dart`  
**Method:** `get()`

```dart
on DioException catch (e, trace) {
  throw Exception('Dio GET request failed: ${e.message} $trace');
}
```

- Dio's default `validateStatus` considers any status code outside 200–299 a `DioException`.
- The `get()` method catches `DioException` and re-throws a plain `Exception`, discarding the HTTP status code.
- The repository and the provider receive only a generic exception string — **there is no code path that detects "this was a 401 specifically" and triggers a token refresh/re-login**.

---

## Root Cause 5 — Token expiry timing is unpredictable from the UI perspective

- The token is fetched at some point during login / first API call.
- The user may stay on the dashboard, navigate between screens, and use the app for any amount of time.
- When ~1 hour has passed since the token was fetched, the **very next API call** (whatever screen happens to trigger it) will get 401.
- This is why the error appears "randomly" — it is precisely at the 1-hour mark of the token's lifetime, regardless of what the user is doing at that moment.

---

## Why hot restart fixes it

| What hot restart does | Why it helps |
|---|---|
| Clears all Dart memory | `TokenManager._accessToken` becomes `null` |
| Re-runs `main()` | Catalyst SDK re-initialises |
| Next API call hits `getToken()` with `_accessToken == null` | `_fetchTokenInternal()` is called → fresh token obtained |
| API call succeeds | 200 response, projects load |

Hot restart is essentially a manual "clear token cache and re-fetch" — which is exactly what the app should be doing automatically.

---

## Potential Solutions

### Solution A — Clear token and retry on 401 in ApiClient (Recommended)

Add a **response/error interceptor** in `ApiClient._internal()` (in `dio_client.dart`) that:
1. Catches any `DioException` where `response.statusCode == 401`.
2. Calls `TokenManager.instance.clearToken()`.
3. Fetches a fresh token via `TokenManager.instance.getToken()`.
4. Retries the original request with the new token by calling `handler.resolve(retryResponse)`.

This is the standard Dio interceptor pattern for OAuth token refresh. No screen or repository code needs to change.

---

### Solution B — Never cache the token in TokenManager; always ask the SDK

In `TokenManager.getToken()`, remove the `if (_accessToken != null) return _accessToken` guard, or add an **expiry timestamp** check:
- Store `_tokenFetchedAt = DateTime.now()` when the token is fetched.
- In `getToken()`, if `DateTime.now().difference(_tokenFetchedAt) > Duration(minutes: 50)`, treat the cached token as expired and call `_fetchTokenInternal()` again.
- 50 minutes is a safe margin before the Catalyst token's 1-hour expiry.

This ensures every API call after ~50 minutes automatically gets a fresh token before the old one actually expires — preventing 401 entirely.

---

### Solution C — Use Catalyst SDK's built-in refresh (if available)

The `zcatalyst_sdk` may expose a method to refresh the token using the stored refresh token (e.g. `app.refreshToken()` or `app.getAccessToken()` may handle refresh internally).
- Check the `zcatalyst_sdk` package documentation/source for a refresh method.
- If it exists, call it in `_fetchTokenInternal()` when `_accessToken` is stale instead of just calling `getAccessToken()` again.
- This delegates expiry and refresh handling to the SDK, which is the most correct approach.

---

### Solution D — On 401, navigate user to login screen

As a fallback safety net (not a primary fix):
- In the 401 error interceptor (Solution A), if the token refresh itself also fails with 401, call `TokenManager.instance.clearToken()`, clear `AuthManager.instance.currentUser`, and navigate to the login screen.
- This prevents the user from being stuck in an authenticated-but-broken state.

---

## Files to change (when implementing the fix)

| File | What to change |
|---|---|
| `lib/core/network/dio_client.dart` | Add error interceptor to catch 401, clear token, retry |
| `lib/core/constants/token_manager.dart` | Add expiry timestamp + proactive refresh before token expires |
| `lib/core/constants/auth_manager.dart` | Add `clearUser()` method for logout-on-auth-failure flow |

---

## Files NOT to change

| File | Reason |
|---|---|
| `lib/repositories/project_repository.dart` | No change needed; fix lives in the HTTP layer |
| `lib/providers/project_provider.dart` | No change needed |
| `lib/views/projects/projects_screen.dart` | No change needed |
