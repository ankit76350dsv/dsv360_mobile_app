# iOS Catalyst Authentication — What Went Wrong & How It Was Fixed

**Date:** 11 March 2026  
**Symptom:** Login/authentication on iPhone simulator was failing silently. The Catalyst SDK was not initializing and OAuth login could not complete on iOS. Android emulator worked fine throughout.

---

## Root Causes

### 1. Missing `AppConfigurationDevelopment.plist` and `AppConfigurationProduction.plist`
**File path:** `ios/Runner/AppConfigurationDevelopment.plist` and `ios/Runner/AppConfigurationProduction.plist`

The Zoho Catalyst SDK on iOS reads these plist files at launch to load its configuration:
- `ClientID` — OAuth client identifier
- `ClientSecretID` — OAuth client secret
- `ProjectID` / `PortalID` — Catalyst project and portal identifiers
- `RedirectURLScheme` — the custom URL scheme (`dsv360`) used to redirect back after login
- `OAuthScopes` — the list of permissions requested
- `APIBaseURL` / `AccountsPortalDomain` — API and accounts portal endpoints

These files were present in the backup project (`dsv360_test`) but were **missing entirely** from the main project (`dsv/dsv`). Without them, the Catalyst SDK silently fails to initialize on iOS and no login is possible.

**Why Android worked:** Android reads its Catalyst config from a different mechanism (assets/zc_app_configuration.json or environment constants), so it was unaffected.

---

### 2. Missing `CFBundleURLTypes` — OAuth redirect URL scheme not registered
**File path:** `ios/Runner/Info.plist`

After the user logs in on the Zoho accounts portal, the browser redirects back to the app using the custom URL scheme `dsv360://`. For iOS to route that redirect back to the app, the scheme **must be declared** in `Info.plist` under `CFBundleURLTypes`.

The main project's `Info.plist` was missing this entry entirely. As a result, after successful login in the browser/web view, the OAuth callback could never return to the app — authentication appeared to hang or fail.

---

### 3. Missing `LSApplicationQueriesSchemes` — app couldn't query `https://` URLs
**File path:** `ios/Runner/Info.plist`

The `LSApplicationQueriesSchemes` key with value `https` was missing. This is required for the app to be able to call `canOpenURL()` on `https://` URLs used during the OAuth login flow.

---

### 4. Wrong `UISceneDelegateClassName` — custom SceneDelegate instead of FlutterSceneDelegate
**File path:** `ios/Runner/Info.plist`

The main project's `Info.plist` used `$(PRODUCT_MODULE_NAME).SceneDelegate` (pointing to a custom empty `SceneDelegate.swift` subclass), while the backup used `FlutterSceneDelegate` directly. Although the custom class extended `FlutterSceneDelegate` and added no overrides, using the direct `FlutterSceneDelegate` class name is safer and matches Flutter's documented iOS setup for handling URL scheme callbacks from OAuth flows.

---

## Files Changed in Main Project (`dsv/dsv`)

### `ios/Runner/AppConfigurationDevelopment.plist` *(new file, copied from backup)*
Added Catalyst SDK development environment configuration including ClientID, ClientSecretID, RedirectURLScheme (`dsv360`), ProjectID, OAuthScopes, APIBaseURL, and AccountsPortalDomain.

### `ios/Runner/AppConfigurationProduction.plist` *(new file, copied from backup)*
Added Catalyst SDK production environment configuration with the production ClientID, ClientSecretID, and AccountsPortalDomain.

### `ios/Runner/Info.plist`
Three changes:
1. Added `CFBundleURLTypes` array registering the `dsv360` URL scheme so iOS can route OAuth callbacks back to the app.
2. Added `LSApplicationQueriesSchemes` with `https` so the app can query HTTPS URLs during the login flow.
3. Changed `UISceneDelegateClassName` from `$(PRODUCT_MODULE_NAME).SceneDelegate` to `FlutterSceneDelegate` to align with Flutter's standard iOS configuration.

### `ios/Runner.xcodeproj/project.pbxproj`
Added `AppConfigurationDevelopment.plist` and `AppConfigurationProduction.plist` to:
- `PBXBuildFile` section (as Resources build files)
- `PBXFileReference` section (file references)
- `PBXGroup` for Runner (so they appear in the Xcode project navigator)
- `PBXResourcesBuildPhase` for Runner (so they are bundled into the app)

---

## Files NOT Changed
- `lib/` — no Dart code changes needed
- `ios/Runner/AppDelegate.swift` — identical in both projects; no change needed
- `ios/Runner/SceneDelegate.swift` — kept as-is (empty subclass of FlutterSceneDelegate; harmless)
- `pubspec.yaml`, `Podfile` — identical in both projects; no change needed
- `ios/Runner.xcodeproj/project.pbxproj` — only the AppConfiguration plist references were added; nothing else touched
- Backup project `dsv360_test` — not touched at all
