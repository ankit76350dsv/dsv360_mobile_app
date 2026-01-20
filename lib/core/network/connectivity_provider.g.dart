// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityStatusHash() =>
    r'980882b6b98a02e431d5f3de24ba9eaffab9e800';

/// See also [connectivityStatus].
@ProviderFor(connectivityStatus)
final connectivityStatusProvider =
    AutoDisposeStreamProvider<List<ConnectivityResult>>.internal(
      connectivityStatus,
      name: r'connectivityStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$connectivityStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityStatusRef =
    AutoDisposeStreamProviderRef<List<ConnectivityResult>>;
String _$checkConnectivityHash() => r'4daf34698fc7f84f7ae97aa402ef6a30c39538b3';

/// See also [checkConnectivity].
@ProviderFor(checkConnectivity)
final checkConnectivityProvider =
    AutoDisposeFutureProvider<List<ConnectivityResult>>.internal(
      checkConnectivity,
      name: r'checkConnectivityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$checkConnectivityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CheckConnectivityRef =
    AutoDisposeFutureProviderRef<List<ConnectivityResult>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
