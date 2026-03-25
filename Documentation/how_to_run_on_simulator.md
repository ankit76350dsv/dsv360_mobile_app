# iOS Simulator Build Fix (Xcode 26+, Apple Silicon)

## Issue
Running `flutter run` on iOS simulator failed with:

1. `Parse Issue (Xcode): Module 'connectivity_plus' not found`
2. `Framework 'Pods_Runner' not found`
3. `Building for 'iOS-simulator', but linking in object file ... ZohoPortalAuthKit ... built for 'iOS'`

## Root Cause
1. The iOS pod build settings were excluding simulator `arm64`, so Flutter plugin modules (including `connectivity_plus`) were not generated correctly for Apple Silicon simulator builds.
2. `zcatalyst_sdk` depends on `ZohoPortalAuth`, and the previously locked pod version (`1.0.5`) caused simulator linker incompatibility.

## Permanent Fix Applied
Only existing files were modified.

### 1) Updated `ios/Podfile`
Changes made:

1. Switched to static framework linkage:
```ruby
use_frameworks! :linkage => :static
```

2. Pinned ZohoPortalAuth to a compatible version:
```ruby
pod 'ZohoPortalAuth', '1.1.0'
```

3. Forced simulator `arm64` support in `post_install`:
```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        flutter_additional_ios_build_settings(target)
        target.build_configurations.each do |config|
            config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = ''
        end
    end
end
```

### 2) Updated iOS pods lock state
`Podfile.lock` was refreshed through CocoaPods, and `ZohoPortalAuth` is now resolved to `1.1.0`.

## Commands Used
```bash
cd ios
pod deintegrate
pod update ZohoPortalAuth
pod install

cd ..
flutter run -d "iPhone 17 Pro"
```

## Result
The app now builds and launches on iOS simulator successfully. The `connectivity_plus` module error is fixed permanently via Podfile configuration and updated pod resolution.


  